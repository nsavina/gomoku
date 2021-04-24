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

interface IPlayer {
    Position readInput();
    char getMark();
    void writeInput(Position pos);
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
    this(char mark, Socket sock) {
        this.mark = mark;
        this.sock = sock;
    }
    auto parser = new Parser();


    Position readInput() {
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

    void writeInput(Position pos) {
        char[4] str = [cast(char)(pos.i + 97), cast(char)(pos.j + 65), '\r', '\n'];
        sock.send(str.idup);
    }

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

class Board {
    IPlayer currentPlayer;
    IPlayer[] players;
    int size = 15;
    static const int nWin = 5;
    char[][] board;

    public:
    this(IPlayer player1, IPlayer player2) {
        this.board = new char[][](this.size, this.size);
        for (int c = 0; c < this.size; c++)
            for (int b = 0; b < this.size; b++)
                this.board[c][b] = '.';

        this.players = [player1, player2];
        this.currentPlayer = player1;
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

    void changeCurrentPlayer () {
        if (this.currentPlayer == this.players[0]) {
            this.currentPlayer = this.players[1];
        }
        else {
            this.currentPlayer = this.players[0];
        }
    }
}
 
int main() {
    auto serv = new TcpSocket();
    serv.bind(new InternetAddress("127.0.0.1", 7000));
    serv.listen(10);
    auto clientX = serv.accept();
    auto clientO = serv.accept();
    clientX.send("X\r\n");
    clientO.send("O\r\n");
    Board board = new Board(new RemotePlayer('X', clientX),
    new RemotePlayer('O', clientO));

    bool control = true;
    bool winner = false;

    do {
        Position pos;
        do {
            board.printBoard();
            writeln;
            pos = board.currentPlayer.readInput();
            control = board.updateBoard(pos);
        } while (!control);

        winner = board.checkWinner();

        board.changeCurrentPlayer();
        board.currentPlayer.writeInput(pos);
    } while (!winner);

    board.printBoard();
    if (board.currentPlayer.getMark() == 'O') {
        clientX.send("You won");
        clientO.send("You lost");
    }
    else {
        clientO.send("You won");
        clientX.send("You lost");
    }
    clientX.close();
    clientO.close();
    serv.close();
    return 0;
}