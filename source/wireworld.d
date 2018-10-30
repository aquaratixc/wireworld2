module wireworld;

private
{
	import qte5;
}

// элементы мира WireWorld
final enum Element : byte 
{
	Empty = 0,        // пустое поле
	Head,         // голова электрона
	Tail,         // хвост электрона
	Conductor     // проводник
}

// мир WireWorld
class WireWorld(size_t WORLD_WIDTH, size_t WORLD_HEIGHT)
{
	private
	{
		// мир
		byte[WORLD_HEIGHT][WORLD_WIDTH] world;
		// копия мира
		byte[WORLD_HEIGHT][WORLD_WIDTH] reserved;

		// резервное копирование мира
		void backupWorld()
		{
			for (int i = 0; i < WORLD_WIDTH; i++)
			{
				for (int j = 0; j < WORLD_HEIGHT; j++)
				{
					reserved[i][j] = world[i][j];
				}
			}
		}
	}

	this()
	{
		
	}

	// извлечение элемента
	auto opIndex(size_t i, size_t j)
	{
		return world[i][j];
	}

	// присвоение элемента
	void opIndexAssign(Element element, size_t i, size_t j)
	{
		world[i][j] = element;
	}

	// одно поколение клеточного автомата
	auto execute()
	{
		// скопировать мир
		backupWorld;

		// трансформация ячейки с проводником
		void transformConductorCell(int i, int j)
		{
			auto up = ((j + 1) >= WORLD_HEIGHT) ? WORLD_HEIGHT - 1 : j + 1;
			auto down = ((j - 1) < 0) ? 0 : j - 1;
			auto right = ((i + 1) >= WORLD_WIDTH) ?  WORLD_WIDTH - 1 : i + 1;
			auto left = ((i - 1) < 0) ? 0 : i - 1;

			auto counter = 0;

			if (reserved[i][up] == Element.Head)
			{
				counter++;
			}

			if (reserved[i][down] == Element.Head)
			{
				counter++;
			}

			if (reserved[left][j] == Element.Head)
			{
				counter++;
			}

			if (reserved[right][j] == Element.Head)
			{
				counter++;
			}

			if (reserved[left][up] == Element.Head)
			{
				counter++;
			}

			if (reserved[left][down] == Element.Head)
			{
				counter++;
			}

			if (reserved[right][up] == Element.Head)
			{
				counter++;
			}

			if (reserved[right][down] == Element.Head)
			{
				counter++;
			}

			if ((counter == 1) || (counter == 2))
			{
				world[i][j] = Element.Head;
			}
			else
			{
				world[i][j] = Element.Conductor;
			}
		}

		for (int i = 0; i < WORLD_WIDTH; i++)
		{
			for (int j = 0; j < WORLD_HEIGHT; j++)
			{
				auto currentCell = reserved[i][j];
				
				final switch (currentCell) with (Element)
				{
					case Empty:
						world[i][j] = Empty;
						break;
					case Head:
						world[i][j] = Tail;
						break;
					case Tail:
						world[i][j] = Conductor;
						break;
					case Conductor:
						transformConductorCell(i, j);
						break;
				}
			}
		}
	}

	// очистка всего мира
	void clearWorld()
	{
		world = typeof(world).init;
	}

	// нарисовать мир с помощью QtE5
	void drawWorld(QPainter painter, int cellWidth, int cellHeight)
	{

	    QColor EmptyColor = new QColor(null);
	    QColor HeadColor = new QColor(null);
	    QColor TailColor = new QColor(null);
	    QColor ConductorColor = new QColor(null);
	    QColor CornerColor = new QColor(null);

		EmptyColor.setRgb(8, 8, 8, 230);
		HeadColor.setRgb(175, 32, 202, 230);
		TailColor.setRgb(88, 146, 210, 230);
		ConductorColor.setRgb(153, 153, 76, 230);
		
		CornerColor.setRgb(133, 133, 133, 230);

		QPen pen = new QPen;
		pen.setColor(CornerColor);

	    for (int i = 0; i < WORLD_WIDTH; i++)
		{
			for (int j = 0; j < WORLD_HEIGHT; j++)
			{
				auto currentCell = world[i][j];

				// рисование прямоугольника
				QRect rect = new QRect;
	    		rect.setRect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);

				final switch (currentCell) with (Element)
				{
					case Empty:
						painter.fillRect(rect, EmptyColor);			
						break;
					case Head:
						painter.fillRect(rect, HeadColor);
						break;
					case Tail:
						painter.fillRect(rect, TailColor);
						break;
					case Conductor:
						painter.fillRect(rect, ConductorColor);
						break;
				}

				painter.setPen(pen);
				painter.drawRect(i * cellWidth, j * cellHeight, cellWidth, cellHeight);
			}
		}
	}
}
