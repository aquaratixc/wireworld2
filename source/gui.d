module gui;

import std.algorithm;
import std.range;

import qte5;

import wireworld;

// состояние мира
enum WORLD_WIDTH  = 220;
enum WORLD_HEIGHT = 200;
enum CELL_WIDTH   = 5;
enum CELL_HEIGHT  = 5;

WireWorld!(WORLD_WIDTH, WORLD_HEIGHT) wireWorld;

extern(C)
{
    void onTimerTick(MainForm* mainFormPointer) 
    {
        (*mainFormPointer).runTimer;
    }

     void onStartButton(MainForm* mainFormPointer) 
    {
        (*mainFormPointer).runStart;
    }

    void onStopButton(MainForm* mainFormPointer) 
    {
        (*mainFormPointer).runStop;
    }

    void onLoadButton(MainForm* mainFormPointer) 
    {
        (*mainFormPointer).runLoad;
    }

    void onSaveButton(MainForm* mainFormPointer) 
    {
        (*mainFormPointer).runSave;
    }
}

extern(C)
{
    void onDrawStep(QWireWorld* wireWorldPointer, void* eventPointer, void* painterPointer) 
    { 
        (*wireWorldPointer).runDraw(eventPointer, painterPointer);
    }

    void onMousePressEvent(QWireWorld* wireWorldPointer, void* eventPointer) 
    {
		(*wireWorldPointer).runMouseEvent(eventPointer);
	}
}

class QWireWorld : QWidget
{
    private
    {
        QWidget parent;
    }

    this(QWidget parent)
    {
        wireWorld = new WireWorld!(WORLD_WIDTH, WORLD_HEIGHT);
        super(parent);
        this.parent = parent;
        setPaintEvent(&onDrawStep, aThis);
    }

    void runDraw(void* eventPointer, void* painterPointer)
    {
      
        QPainter painter = new QPainter('+', painterPointer);

        wireWorld.drawWorld(painter, CELL_WIDTH, CELL_HEIGHT);
       
        painter.end;
    }

    void runMouseEvent(void* eventPointer)
    {
        QMouseEvent qe = new QMouseEvent('+', eventPointer);
        
        auto X = qe.x;
        auto Y = qe.y;
        auto rX = -1;
        auto rY = -1;

        foreach (i; 0..WORLD_WIDTH)
        {
            auto x = i * CELL_WIDTH;
            auto xx = x + CELL_WIDTH;

            if ((x >= X) && (X <= xx))
            {
                rX = i;
                break;
            }
        }
        
        foreach (i; 0..WORLD_HEIGHT)
        {
            auto y = i * CELL_HEIGHT;
            auto yy = y + CELL_HEIGHT;

            if ((y > Y) && (Y < yy))
            {
                rY = i;
                break;
            }
        }

        rX -= 1;
        rY -= 1;

        if ((rX != -1) && (rY != -1))
        {
            switch ((cast(MainForm) parent).get)
            {
                case "Empty":
                    wireWorld[rX, rY] = Element.Empty;
                    break;
                case "Head":
                    wireWorld[rX, rY] = Element.Head;
                    break;
                case "Tail":
                    wireWorld[rX, rY] = Element.Tail;
                    break;
                case "Conductor":
                    wireWorld[rX, rY] = Element.Conductor;
                    break;
                default:
                    break;
            }
            this.update;
        }
    }
}
 
// псевдонимы под Qt'шные типы
alias WindowType = QtE.WindowType;

// основное окно
class MainForm : QWidget
{
    private
    {
        QHBoxLayout mainBox;
        QVBoxLayout vbox0, vbox1, vbox2;
        QGridLayout grid0;
        QGroupBox group0, group1, group2;
        QWireWorld box0;
        QPushButton button, button0, button1, button2;
        QTimer timer;
        QAction action, action0, action1, action2, action3;
    }

    protected  QComboBox combo0;

   
    this(QWidget parent, WindowType windowType) 
	{
		super(parent, windowType); 
        showMaximized;
		setWindowTitle("WireWorld2");

        mainBox = new QHBoxLayout(null);

        vbox0 = new QVBoxLayout(null);

        box0 = new QWireWorld(this);
        box0.saveThis(&box0);
        box0.setMousePressEvent(&onMousePressEvent, box0.aThis());

        vbox0.addWidget(box0);

        group0 = new QGroupBox(null);
        group0.setFixedWidth(1050);
        group0.setText("Wireworld");
		group0.setLayout(vbox0);

        vbox1 = new QVBoxLayout(null);

        combo0 = new QComboBox(null);
		[
			"Empty",
            "Head",
            "Tail",
            "Conductor"
		]
				 .enumerate(0)
				 .each!(a => combo0.addItem(a[1], a[0]));

        vbox1.addWidget(combo0);

        group1 = new QGroupBox(null);
        group1.setFixedWidth(225);
        group1.setFixedHeight(70);
        group1.setText("Wireworld elements");
		group1.setLayout(vbox1);

        grid0 = new QGridLayout(null);

       	button = new QPushButton("Load world...", this);
        button0 = new QPushButton("Start", this);
        button1 = new QPushButton("Stop", this);
        button2 = new QPushButton("Save world...", this);
        
        timer = new QTimer(this);
        timer.setInterval(100); 

        action  = new QAction(this, &onLoadButton, aThis);
        action0 = new QAction(this, &onTimerTick, aThis);
        action1 = new QAction(this, &onStartButton, aThis);
        action2 = new QAction(this, &onStopButton, aThis);
        action3 = new QAction(this, &onSaveButton, aThis);
        
        connects(timer, "timeout()", action0, "Slot()");
        connects(button, "clicked()", action, "Slot()");
        connects(button0, "clicked()", action1, "Slot()");
        connects(button1, "clicked()", action2, "Slot()");
        connects(button0, "clicked()", timer, "start()");
        connects(button1, "clicked()", timer, "stop()");
        connects(button2, "clicked()", action3, "Slot()");
        
        grid0
            .addWidget(button, 0, 0)
            .addWidget(button2, 0, 1)
            .addWidget(button0, 1, 0)
            .addWidget(button1, 1, 1);

        group2 = new QGroupBox(null);
        group2.setFixedWidth(225);
        group2.setFixedHeight(100);
        group2.setText("Wireworld control");
		group2.setLayout(grid0);

        vbox2 = new QVBoxLayout(null);
        vbox2
            .addWidget(group1)
            .addWidget(group2)
            .addWidget(new QWidget(null));
        
        mainBox
            .addWidget(group0)
            .addLayout(vbox2);

        setLayout(mainBox);
    }

    @property auto get()
    {
        return combo0.text!string;
    }

    void runTimer()
    {
    	wireWorld.execute;
        box0.update;
    }

    void runStart()
    {
        button0.setEnabled(false);
        button1.setEnabled(true);
    }

    void runStop()
    {
        button0.setEnabled(true);
        button1.setEnabled(false);
    }

    void runLoad()
    {
       import std.stdio;
       import std.conv;
       import std.file;
       import std.string;
       
       QFileDialog fileDialog = new QFileDialog('+', null);
       string filename = fileDialog.getOpenFileNameSt("Open WireWorld File", "", "*.wwd *.txt");   	

       if (filename != "")
       {
            auto content = (cast(string) std.file.read(filename)).replace("\n", "");

            foreach (i, e; content)
            {
                auto x = i / WORLD_WIDTH;
                auto y = i % WORLD_HEIGHT;
                // перевод символа в число (код 0 в ASCII = 48
                auto k = to!int(e) - 48;

                switch (k)
                {
                        case 0:
                                wireWorld[x, y] = Element.Empty;
                                break;
                        case 1:
                                wireWorld[x, y] = Element.Head;
                                break;
                        case 2:
                                wireWorld[x, y] = Element.Tail;
                                break;
                        case 3:
                                wireWorld[x, y] = Element.Conductor;
                                break;
                        default:
                                break;
                }
            }
       }
    }

    void runSave()
    {
        import std.stdio;
        
        QFileDialog fileDialog = new QFileDialog('+', null);
        string filename = fileDialog.getSaveFileNameSt("Save WireWorld File", "", "*.wwd *.txt");
        
        if (filename != "")
        {
            File file;
            file.open(filename, "w");

            foreach (x; 0..WORLD_WIDTH)
            {
                foreach (y; 0..WORLD_HEIGHT)
                {
                    file.write(wireWorld[x, y]);
                }
                file.writeln;
            }
        }
    }
}
