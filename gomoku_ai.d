import std.stdio;
import std.algorithm;
import std.array;
import std.conv;
import std.string;
import std.csv;
import core.stdc.wchar_;
import std.math;
import std.system;
import std.socket;
import std.regex;
import std.random;


interface IPlayer {
    Position readInput(Board board);
    char getMark();
    void writeInput(Position pos);
}

class AiPlayer : IPlayer {
    char mark;
    Socket sock;

    this(char mark, Socket sock) {
        this.mark = mark;
        this.sock = sock;
    }

    Position readInput(Board board) {
        Estimate estimate = board.minmax(board.board[][], 2, false);
        writeln("position ", estimate.position.i, estimate.position.j);
        writeln("value ", estimate.value);
        Position turn = estimate.position;
        return new Position(turn.i, turn.j);
    }

    char getMark() {
        return mark;
    }

    void writeInput(Position pos) {
        char[4] str = [cast(char)(pos.i + 97), cast(char)(pos.j + 65), '\r', '\n'];
        sock.send(str.idup);
    }
}

class Parser {
  string prebuf;

  string nextMessage(string buf) {
    string all = prebuf ~ buf;
    auto splitter = all.findSplit("\r\n");

    if (splitter[1] != "") {
        if (splitter[2]) {
            prebuf = splitter[2];
        }
        else prebuf = "";
        return splitter[0];
    }
    else {
        prebuf = all;
        return "";
    }
  }
}

class RemotePlayer : IPlayer {
    char mark;
    Socket sock;
    auto parser = new Parser();
    this(char mark, Socket sock) {
        this.mark = mark;
        this.sock = sock;
    }

    Position readInput(Board board) {
        string message;
        char[4] buf;
        size_t size;

        do {
            size = sock.receive(buf);
            string s = to!string(buf[0..size]);

            message = parser.nextMessage(s);
            return new Position(message[0] - 97, message[1] - 65);

        } while (!message.empty);

        return new Position(0, 0);
    }

    void writeInput(Position pos) {}

    char getMark() {
        return mark;
    }
}

class Position {
    int i;
    int j;

    this(int i, int j) {
        this.i = i;
        this.j = j; 
    }
};

struct Estimate {
    Position position;
    double value;
}

struct Pattern {
    string s;
    int w;
};

struct Direction {
    int n;
    int m;
    int w;
};

class Board {
    IPlayer currentPlayer;
    IPlayer[] players;
    int size = 15;
    static const int nWin = 5;
    char[][] board;

    // for ai realisation
    Pattern[] patterns = [
        Pattern("sssss", 99999),
        Pattern(".ssss.", 7000),
        Pattern(".ssss", 4000),
        Pattern("ssss.", 4000),
        Pattern(".s.sss", 2000),
        Pattern(".ss.ss", 2000),
        Pattern(".sss.s", 2000),
        Pattern("sss.s.", 2000),
        Pattern("ss.ss.", 2000),
        Pattern("s.sss.", 2000),
        Pattern(".sss.", 3000),
        Pattern(".sss", 1500),
        Pattern("sss.", 1500),
        Pattern(".ss.s", 800),
        Pattern(".s.ss", 800),
        Pattern("ss.s.", 800),
        Pattern("s.ss.", 800),
        Pattern(".ss.", 20),
    ];

    public:

    bool checkHasNeighbours(char[][] field, int a, int b) {
        if (a >= 1 && (b >= 1 && field[a - 1][b - 1] != '.' || field[a - 1][b] != '.' || b <= field.length - 2 && field[a - 1][b + 1] != '.' ))
            return true;
        if (a <= field.length - 2 && (b >= 1 && field[a + 1][b - 1] != '.' || field[a + 1][b] != '.' || b <= field.length - 2 && field[a + 1][b + 1] != '.' ))
            return true;
        if (b >= 1 && field[a][b - 1] != '.' || b <= field.length - 2 && field[a][b + 1] != '.')
            return true;
        return false;
    }


    Position[] getAllFree(char[][] field) {
        Position[] tmp = new Position[](255);
        int counter = 0;

        for (int i = 0; i < field.length; i++) {
            for (int j = 0; j < field[i].length; j++) {
                if (field[i][j] == '.' &&
                    checkHasNeighbours(field, i, j)
                ) {
                    tmp[counter] = new Position(i, j);
                    counter++;
                }
            }
        }

        Position[] res;
        res = tmp[0..counter];

        return res;
    }

    double estimate(char[][] field, Position p, char mark) {
        // writeln(p.i, p.j);
        int max = 0;
        int length = to!int(field.length);
        foreach (Pattern pattern; patterns) {
                string patternString = pattern.s.replace('s', mark);
                int topDistance = p.i < 4 ? p.i : 4;
                int iTop = p.i - topDistance;
                int bottomDistance = length - 1 - p.i <= 4 ? length - 1 - p.i : 4;
                int iBottom = p.i + bottomDistance;
                int leftDistance = p.j < 4 ? p.j : 4;
                int jLeft = p.j - leftDistance;
                int rightDistance = length - 1 - p.j <= 4 ? length - 1 - p.j : 4;
                int jRight = p.j + rightDistance;

                // writeln("leftDistance ", leftDistance);
                // writeln("topDistance ", topDistance);
                // writeln("rightDistance ", rightDistance);
                // writeln("bottomDistance ", bottomDistance);

                int leftTopDistance = min(leftDistance, topDistance);
                int rightTopDistance = min(rightDistance, topDistance);
                int rightBottomDistance = min(rightDistance, bottomDistance);
                int leftBottomDistance = min(leftDistance, bottomDistance);

                char[] arrHorizontal = new char[leftDistance + 1 + rightDistance];
                int c = 0;
                for (int j = jLeft; j <= jRight; j++) {
                    arrHorizontal[c] = field[p.i][j];
                    c++;
                }
                string s = arrHorizontal.idup();
                if (s.findSplit(patternString)[1] != "") {
                    max = max + pattern.w;
                }

                char[] arrVertical = new char[topDistance + 1 + bottomDistance];
                c = 0;
                for (int i = iTop; i <= iBottom; i++) {
                    arrVertical[c] = field[i][p.j];
                    c++;
                }
                s = arrVertical.idup();
                if (s.findSplit(patternString)[1] != "") {
                    max = max + pattern.w;
                }

                char[] arrLeftDiagonal = new char[leftTopDistance + 1 + rightBottomDistance];
                c = 0;
                for (int i = -leftTopDistance; i <= rightBottomDistance; i++) {
                    arrLeftDiagonal[c] = field[p.i + i][p.j + i];
                    c++;
                }
                s = arrLeftDiagonal.idup();
                if (s.findSplit(patternString)[1] != "") {
                    max = max + pattern.w;
                }

                char[] arrRightDiagonal = new char[rightTopDistance + 1 + leftBottomDistance];
                c = 0;
                for (int i = -leftBottomDistance; i <= rightTopDistance; i++) {
                    arrRightDiagonal[c] = field[p.i - i][p.j + i];
                    c++;
                }
                s = arrRightDiagonal.idup();
                if (s.findSplit(patternString)[1] != "") {
                    max = max + pattern.w;
                }
                // hH iG  iI iH gH hI jI hG gF fE

        }
        return max;
        // mark == 'O' ? max * 1.1 : max;
    }

    Estimate minmax(char[][] field, int depth, bool isMax) {
        Position[] turns = getAllFree(field);
        double best = isMax ? -double.infinity : double.infinity;
        Position[] bestTurns = new Position[turns.length];
        int counter = 0;

        int length = to!int(field.length);
        if (turns.length == length * length) {
            return *(new Estimate(new Position(length / 2, length / 2), best));
        }

        char curMark = isMax ? 'X' : 'O';

        foreach (p; turns) {
            field[p.i][p.j] = curMark;
            double cur;

            if (depth == 1) {
                cur = estimate(field, p, curMark);
            }
            else {
                cur = minmax(field, depth - 1, !isMax).value;
            }

            writeln("depth ", depth, " is max ", isMax, " current position ", p.i, " ", p.j, " current estimate ", cur);
//  || !isMax && cur < best
            if (isMax && cur > best || !isMax && cur < best) {
                best = cur;
                counter = 0;
                bestTurns = new Position[turns.length];
                bestTurns[counter] = p;
            }
            if (cur == best) {
                bestTurns[counter] = p;
                counter++;
            }
            field[p.i][p.j] = '.';
        }

        auto rnd = Random(unpredictableSeed);
        auto randomIndex = uniform(0, counter, rnd);

        Position bestTurn = bestTurns[randomIndex];

        return Estimate(bestTurn, best);
    }


    this(IPlayer player1, IPlayer player2) {
        this.board = new char[][](this.size, this.size);
        for (int c = 0; c < this.size; c++)
            for (int b = 0; b < this.size; b++)
                this.board[c][b] = '.';

        this.players = [player1, player2];
        this.currentPlayer = player1;
        // this.init();
    }

    void printBoard() {
        write(" ");
        for(int row = 0; row < this.size; row++) {
            write(" ", cast(char) (row + 65));
        }
        writeln;
        foreach(numrow, row; this.board[0..$]) {
            write(cast(char) (numrow + 97), " ");
            foreach(numcol, col; row[0..$]) {
                write(row[numcol], " ");
            }
            writeln;
        }
    }
 
    bool checkPosition(Position pos) {
        if (pos.i >= this.size || pos.i < 0 || pos.j >= this.size || pos.j < 0)
            return false;
        if (this.board[pos.i][pos.j] == '.')
            return true;
        else
            return false;
    }

    bool updateBoard(Position pos) {
        if (checkPosition(pos)) {
            this.board[pos.i][pos.j] = this.currentPlayer.getMark();
            return true;
        }
        else
            return false;
    }

    bool checkWinner() {
        int playerCount, d, e, x, y;

        for (d = 0; d < this.size; d++) {
            playerCount = 0;
            for (e = 0; e < this.size; e++) {
                if (this.board[d][e] == this.currentPlayer.getMark())
                    playerCount += 1;
                else
                    playerCount = 0;

                if (playerCount >= nWin)
                    return true;
            }
        }

        for (e = 0; e < this.size; e++) {
            playerCount = 0;
            for (d = 0; d < this.size; d++) {
                if (this.board[d][e] == this.currentPlayer.getMark())
                    playerCount += 1;
                else
                    playerCount = 0;

                if (playerCount >= nWin)
                    return true;
            }
        }

        for (y = this.size, x = 0; y > 0; x++, y--) {
            playerCount = 0;
            for (d = y, e = 0; d < x; d++, e++) {
                if (this.board[d][e] == this.currentPlayer.getMark())
                    playerCount += 1;
                else
                    playerCount = 0;

                if (playerCount >= nWin)
                    return true;
            }
        }

        for (x = this.size, y = 0; x > 0; x--, y++) {
            playerCount = 0;
            for (d = 0, e = y; e < x; d++, e++) {
                if (this.board[d][e] == this.currentPlayer.getMark())
                    playerCount += 1;
                else
                    playerCount = 0;

                if (playerCount >= nWin)
                    return true;
            }
        }

        return false;
    }

    void changeCurrentPlayer() {
        if (this.currentPlayer == this.players[0]) {
            this.currentPlayer = this.players[1];
        }
        else {
            this.currentPlayer = this.players[0];
        }
    }
}

import core.stdc.assert_;
 
int main() {
    // auto sock = new TcpSocket(new InternetAddress("49.12.3.28", 7000));
    // int a = 10;
    // a = 20;
    // int* p;
    // *p = a;
    auto sock = new TcpSocket(new InternetAddress("127.0.0.1", 7000));
    char[3] buf;
    sock.receive(buf);
    Board board;
    if (buf[0] == 'X') {
        board = new Board(new AiPlayer('X', sock), new RemotePlayer('O', sock));
    }
    else {
        board = new Board(new RemotePlayer('X', sock), new AiPlayer('O', sock));
    }

    bool control = true;
    bool winner = false;

    do {
        Position pos;
        do {
            board.printBoard();
            writeln;
            pos = board.currentPlayer.readInput(board);
            control = board.updateBoard(pos);
        } while (!control);

        board.currentPlayer.writeInput(pos);
        winner = board.checkWinner();

        if (!winner) {
            board.changeCurrentPlayer();
        }
    } while (!winner);

    board.printBoard();

    char[100] res;
    size_t size;
    size = sock.receive(res);
    writeln(to!string(res[0..size]));

    sock.close();
    return 0;
}
