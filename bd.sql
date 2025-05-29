CREATE TYPE admin_status AS ENUM ('Активен', 'Заблокирован');
CREATE TYPE education_form AS ENUM ('Очная', 'Заочная', 'Очно-заочная');
CREATE TYPE application_status AS ENUM ('Одобрена', 'Отклонена', 'На рассмотрении');
CREATE TYPE material_type AS ENUM ('Видео', 'Текст', 'Тест', 'Файл');
CREATE TYPE year_status AS ENUM ('Архивный', 'Текущий');
CREATE TYPE attempt_status AS ENUM ('Завершена', 'В процессе', 'Провалена');

-- 1. Пользователь
CREATE TABLE users (
    id_user INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    name_user VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX idx_users_email ON users(email);

INSERT INTO users (name_user, email, password)
VALUES
    ('Иванов Иван Иванович', 'ivan@mail.ru', 'password'),
    ('Марков Марк Маркович', 'mark@mail.ru', 'securepassword'),
    ('Алексеев Алексей Алексеевич', 'alexey@mail.ru', 'pass'),
    ('Сидоров Виктор Викторович', 'viktor@mail.ru', 'strongpass'),
    ('Михайлов Михаил Михайлович', 'michael@mail.ru', 'spass'),
    ('Дмитриев Дмитрий Дмитриевич', 'dmitry@mail.ru', 'gpass'),
    ('Петров Петр Петрович', 'petr@mail.ru', 'mypassword'),
    ('Аверин Иван Петрович', 'aip@mail.ru', 'password100'),
    ('Петров Максим Алексеевич', 'pma@mail.ru', 'my00pass'),
    ('Кириллова Мария Петровна', 'maria@mail.ru', 'my_password'),
    ('Мухина Елена Ивановна', 'mei@mail.ru', 'pass0101');

-- 2. Администратор
CREATE TABLE administrator (
    id_admin INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_user INT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    status admin_status NOT NULL DEFAULT 'Активен',
    UNIQUE (id_user)
);

CREATE INDEX idx_administrator_user ON administrator(id_user);
CREATE INDEX idx_administrator_status ON administrator(status);

INSERT INTO administrator (id_user, status)
VALUES
    (1, 'Активен'),
    (2, 'Заблокирован');

-- 3. Вольнослушатель
CREATE TABLE auditor (
    id_auditor INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_user INT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    UNIQUE (id_user)
);

INSERT INTO auditor (id_user)
VALUES
    (5),
    (6);

-- 4. Факультет
CREATE TABLE faculty (
    id_faculty INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    faculty_name VARCHAR(255) NOT NULL,
    UNIQUE (faculty_name)
);

INSERT INTO faculty (faculty_name)
VALUES
    ('Биологический факультет'),
    ('Математический факультет'),
    ('Физический факультет');

-- 5. Преподаватель
CREATE TABLE teacher (
    id_teacher INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_user INT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    id_faculty INT NOT NULL REFERENCES faculty(id_faculty) ON DELETE CASCADE,
    post_teacher VARCHAR(255) NOT NULL,
    UNIQUE (id_user)
);

CREATE INDEX idx_teacher_faculty ON teacher(id_faculty);

INSERT INTO teacher (id_user, id_faculty, post_teacher)
VALUES
    (3, 1, 'Доцент'),
    (4, 2, 'Профессор');

-- 6. Группа
CREATE TABLE student_group (
    id_group INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_faculty INT NOT NULL REFERENCES faculty(id_faculty) ON DELETE CASCADE,
    name_group VARCHAR(100) NOT NULL,
    course_number INT NOT NULL CHECK (course_number BETWEEN 1 AND 6),
    form_education education_form NOT NULL,
    UNIQUE (name_group)
);

CREATE INDEX idx_group_faculty ON student_group(id_faculty);
CREATE INDEX idx_group_course ON student_group(course_number);

INSERT INTO student_group (id_faculty, name_group, course_number, form_education)
VALUES
    (2, 'MT-101', 1, 'Очная'),
    (2, 'MT-401', 4, 'Очная'),
    (1, 'БИО-301', 3, 'Заочная'),
    (3, 'ФИЗ-301', 3, 'Очно-заочная');

-- 7. Студент
CREATE TABLE student (
    id_student INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_user INT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    id_group INT REFERENCES student_group(id_group) ON DELETE CASCADE,
    enrollment_date DATE DEFAULT CURRENT_DATE,
    UNIQUE (id_user)
);

CREATE INDEX idx_student_group ON student(id_group);

INSERT INTO student (id_user, id_group)
VALUES
    (7, 1),
    (8, 1),
    (9, 2),
    (10, 2),
    (11, 3);

-- 8. Подразделение
CREATE TABLE division (
    id_division INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_faculty INT NOT NULL REFERENCES faculty(id_faculty) ON DELETE CASCADE,
    department VARCHAR(255) NOT NULL
);

CREATE INDEX idx_division_faculty ON division(id_faculty);

INSERT INTO division (id_faculty, department)
VALUES
    (1, 'Кафедра микробиологии, иммунологии и общей биологии'),
    (1, 'Кафедра радиационной биологии'),
    (2, 'Кафедра вычислительной математики'),
    (2, 'Кафедра вычислительной механики и информационных технологий'),
    (3, 'Кафедра общей и теоретической физики'),
    (3, 'Кафедра физики конденсированного состояния');

-- 9. Кафедра преподавателя
CREATE TABLE teacher_division (
    id_teacher INT NOT NULL REFERENCES teacher(id_teacher) ON DELETE CASCADE,
    id_division INT NOT NULL REFERENCES division(id_division) ON DELETE CASCADE,
    PRIMARY KEY (id_teacher, id_division)
);

INSERT INTO teacher_division (id_teacher, id_division)
VALUES
    (1, 1),
    (1, 2),
    (2, 3),
    (2, 4);

-- 10. Учебный год
CREATE TABLE academic_year (
    id_year INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    year INT NOT NULL,
    status year_status NOT NULL,
    UNIQUE (year)
);

INSERT INTO academic_year (year, status)
VALUES
    (2023, 'Архивный'),
    (2024, 'Архивный'),
    (2025, 'Текущий');

-- 11. Курс
CREATE TABLE course (
    id_course INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_year INT REFERENCES academic_year(id_year) ON DELETE CASCADE,
    id_teacher INT NOT NULL REFERENCES teacher(id_teacher) ON DELETE CASCADE,
    id_group INT REFERENCES student_group(id_group) ON DELETE CASCADE,
    name_course VARCHAR(255) NOT NULL,
    description_course TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_course_teacher ON course(id_teacher);
CREATE INDEX idx_course_group ON course(id_group);
CREATE INDEX idx_course_year ON course(id_year);

INSERT INTO course (id_year, id_teacher, id_group, name_course, description_course)
VALUES
    (3, 2, 1, 'Web-программирование', 'Изучение на языке Python'),
    (3, 2, 2, 'Эконометрика', 'Изучение количественных и качественных экономических взаимосвязей с помощью математических методов');

-- 12. Заявка на курс
CREATE TABLE course_application (
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    id_auditor INT NOT NULL REFERENCES auditor(id_auditor) ON DELETE CASCADE,
    status application_status NOT NULL DEFAULT 'На рассмотрении',
    applied_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMPTZ,
    processed_by INT REFERENCES users(id_user),
    PRIMARY KEY (id_course, id_auditor)
);

CREATE INDEX idx_application_course ON course_application(id_course);
CREATE INDEX idx_application_auditor ON course_application(id_auditor);
CREATE INDEX idx_application_status ON course_application(status);

INSERT INTO course_application (id_course, id_auditor, status)
VALUES
    (1, 1, 'Одобрена'),
    (2, 2, 'На рассмотрении');

-- 13. Запись на курс
CREATE TABLE course_enrollment (
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    id_student INT NOT NULL REFERENCES student(id_student) ON DELETE CASCADE,
    enrolled_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_course, id_student)
);

CREATE INDEX idx_enrollment_course ON course_enrollment(id_course);
CREATE INDEX idx_enrollment_student ON course_enrollment(id_student);

INSERT INTO course_enrollment (id_course, id_student)
VALUES
    (1, 1),
    (2, 2);

-- 14. Модули курса
CREATE TABLE course_module (
    id_module INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    name_module VARCHAR(255) NOT NULL,
    description_module TEXT,
    sequence_number_module INT NOT NULL,
    UNIQUE (id_course, sequence_number_module)
);

CREATE INDEX idx_module_course ON course_module(id_course);

INSERT INTO course_module (id_course, name_module, description_module, sequence_number_module)
VALUES 
    (1, 'Введение в программирование', 'Основные понятия', 1),
    (1, 'Лекция 2', 'Разбор операторов', 2),
    (1, 'Функции', 'Как использовать функции', 3),
    (2, 'Лекция 1', 'Лабораторная работа 1 заключается в...', 1),
    (2, 'Лекция 2', 'Математическое ожидание', 2);

-- 15. Материал курса
CREATE TABLE course_material (
    id_material INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    id_module INT NOT NULL REFERENCES course_module(id_module) ON DELETE CASCADE,
    type material_type NOT NULL,
    content_material TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    file_url VARCHAR(255)
);

CREATE INDEX idx_material_course ON course_material(id_course);
CREATE INDEX idx_material_module ON course_material(id_module);

INSERT INTO course_material (id_course, id_module, type, content_material, file_url)
VALUES
    (1, 1, 'Текст', 'Основы программирования', NULL),
    (1, 2, 'Видео', 'Домашняя работа: Прикрепляю ссылку на видео', 'https://www.youtube.com'),
    (2, 1, 'Тест', 'Промежуточный тест по функциям', NULL),
    (2, 2, 'Файл', 'Лекция 1', 'hello.pdf');

-- 16. Настройки курса
CREATE TABLE course_settings (
    id_course INT PRIMARY KEY REFERENCES course(id_course) ON DELETE CASCADE,
    visibility BOOLEAN NOT NULL DEFAULT TRUE,
    allow_self_enrollment BOOLEAN NOT NULL DEFAULT FALSE
);

INSERT INTO course_settings (id_course, visibility)
VALUES 
    (1, TRUE),
    (2, FALSE);

-- 17. Файл
CREATE TABLE file (
    id_file INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_user INT NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    name_file VARCHAR(255) NOT NULL,
    type_file VARCHAR(50) NOT NULL,
    link_file TEXT NOT NULL,
    upload_date_file TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description_file TEXT
);

INSERT INTO file (id_user, id_course, name_file, type_file, link_file, description_file)
VALUES 
    (3, 1, 'Введение в программирование', 'PDF', 'programming.pdf', 'Учебный материал'),
    (3, 1, 'Лекция 2 - Основы', 'PDF', 'basics.pdf', 'Вторая лекция по SQL'),
    (2, 2, 'Домашнее задание 1', 'pptx', 'algorithms.pptx', ''),
    (5, 2, 'ДЗ 2', 'docx', 'test.docx', '');

-- 18. Тест
CREATE TABLE test (
    id_test INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    id_module INT NOT NULL REFERENCES course_module(id_module) ON DELETE CASCADE,
    description_test TEXT NOT NULL,
    maximum_score INT NOT NULL,
    time_limit INTERVAL,
    attempts_allowed INT DEFAULT 1
);

CREATE INDEX idx_test_course ON test(id_course);
CREATE INDEX idx_test_module ON test(id_module);

INSERT INTO test (id_course, id_module, description_test, maximum_score, time_limit, attempts_allowed)
VALUES 
    (1, 1, 'Тест по введению в программирование', 100, '30 minutes', 5),
    (1, 2, 'Тест по циклам и условиям', 100, '45 minutes', 3);

-- 19. Вопросы теста
CREATE TABLE test_question (
    id_question INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_test INT NOT NULL REFERENCES test(id_test) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    sequence_number_question INT NOT NULL,
    is_text_answer BOOLEAN DEFAULT FALSE,
    question_score INT,
    CHECK (question_score > 0 OR question_score IS NULL)
);

CREATE INDEX idx_question_test ON test_question(id_test);

INSERT INTO test_question (id_test, question_text, sequence_number_question, question_score)
VALUES 
    (1, 'Что такое переменная?', 1, 10),
    (1, 'Какой оператор используется для вывода данных в Python?', 2, 20),
    (2, 'Какой оператор используется для условных выражений?', 1, 10);

-- 20. Вариант ответа
CREATE TABLE test_option (
    id_option INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_question INT NOT NULL REFERENCES test_question(id_question) ON DELETE CASCADE,
    selection_option TEXT NOT NULL,
    score_answer INT NOT NULL DEFAULT 0,
    sequence_number_option INT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE INDEX idx_option_question ON test_option(id_question);

INSERT INTO test_option (id_question, selection_option, score_answer, sequence_number_option, is_correct)
VALUES 
    (1, 'A) Число', 0, 1, FALSE),
    (1, 'B) Контейнер', 10, 2, TRUE),
    (1, 'C) Функция', 0, 3, FALSE),

    (2, 'A) print', 20, 1, TRUE),
    (2, 'B) echo', 0, 2, FALSE),
    (2, 'C) show', 0, 3, FALSE),

    (3, 'A) if', 10, 1, TRUE),
    (3, 'B) for', 0, 2, FALSE),
    (3, 'C) while', 0, 3, FALSE);

-- 21. Результаты теста
CREATE TABLE test_result (
    id_result INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_test INT NOT NULL REFERENCES test(id_test) ON DELETE CASCADE,
    id_student INT NOT NULL REFERENCES student(id_student) ON DELETE CASCADE,
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    score INT NOT NULL CHECK (score >= 0),
    max_score INT NOT NULL CHECK (max_score > 0),
    percentage NUMERIC(5,2) GENERATED ALWAYS AS (
        CASE WHEN max_score = 0 THEN 0 
        ELSE ROUND((score::NUMERIC / max_score) * 100, 2) 
        END
    ) STORED,
    started_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMPTZ,
    time_spent INTERVAL GENERATED ALWAYS AS (
        finished_at - started_at
    ) STORED,
    attempt_number INT NOT NULL DEFAULT 1,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Завершена', 'В процессе', 'Провалена')),    
    UNIQUE (id_test, id_student, attempt_number)
);

CREATE INDEX idx_test_result_test ON test_result(id_test);
CREATE INDEX idx_test_result_student ON test_result(id_student);
CREATE INDEX idx_test_result_course ON test_result(id_course);
CREATE INDEX idx_test_result_attempt ON test_result(id_test, id_student, attempt_number);

INSERT INTO test_result (id_test, id_course, id_student, score, max_score, started_at, finished_at, attempt_number, status) 
VALUES 
    (1, 1, 1, 85, 100, '2025-02-10 10:00', '2025-02-10 10:30', 1, 'Завершена'),
    (1, 1, 2, 95, 100, '2025-01-18 15:00', '2025-01-18 15:30', 1, 'Завершена'), 
    (1, 1, 3, 70, 100, '2025-01-18 13:56', '2025-01-18 14:26', 1, 'Завершена'), 
    (2, 2, 4, 70, 100, '2024-11-08 11:15', '2024-11-08 12:00', 1, 'Завершена'), 
    (2, 2, 5, 60, 100, '2024-02-16 08:30', '2024-02-16 09:15', 1, 'Завершена'); 

-- 22. Журнал
CREATE TABLE journal (
    id_journal INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_test INT NOT NULL REFERENCES test(id_test) ON DELETE CASCADE,
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    id_group INT NOT NULL REFERENCES student_group(id_group) ON DELETE CASCADE,
    id_student INT NOT NULL REFERENCES student(id_student) ON DELETE CASCADE,
    date_attempt TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    score INT,
    max_score INT,
    percentage NUMERIC(5,2) GENERATED ALWAYS AS (
        CASE WHEN max_score = 0 THEN 0 
        ELSE ROUND((score::NUMERIC / max_score) * 100, 2) 
        END
    ) STORED,
    UNIQUE (id_test, id_student)
);

INSERT INTO journal (id_test, id_course, id_group, id_student, date_attempt, score, max_score)
VALUES 
    (1, 1, 1, 1, '2025-02-10 10:30', 85, 100),
    (1, 1, 1, 2, '2025-01-18 15:30', 95, 100),
    (1, 1, 2, 3, '2025-01-18 14:26', 90, 100),
    (2, 2, 1, 4, '2024-11-08 12:00', 70, 100),
    (2, 2, 3, 5, '2024-02-16 09:15', 60, 100);

-- 23. Задание
CREATE TABLE task (
    id_task INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    id_module INT REFERENCES course_module(id_module) ON DELETE CASCADE,
    id_file INT REFERENCES file(id_file) ON DELETE CASCADE,
    name_task VARCHAR(255) NOT NULL,
    description_task TEXT,
    task_text TEXT NOT NULL,
    deadline TIMESTAMPTZ NOT NULL,
    maximum_score INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_task_course ON task(id_course);
CREATE INDEX idx_task_module ON task(id_module);
CREATE INDEX idx_task_deadline ON task(deadline);

INSERT INTO task (id_course, id_module, id_file, name_task, description_task, task_text, deadline, maximum_score)
VALUES 
    (1, 1, 1, 'Задача 1 по программированию', 'Решите задачу на вывод чисел от 1 до 10.', 'Напишите программу на Python, которая выводит числа от 1 до 10', '2025-03-15', 100),
    (1, 2, 2, 'Задача 2 по программированию', 'Напишите программу для расчета факториала числа.', 'Создайте функцию, которая вычисляет факториал числа', '2025-02-20', 100),
    (2, 5, 3, 'Задача 1 по эконометрике', 'Решите задачу на оценку коэффициентов линейной регрессии.', 'Используя метод наименьших квадратов, найдите коэффициенты линейной регрессии для заданных данных.', '2025-03-25', 100);

-- 24. Оценка задания
CREATE TABLE task_grade (
    id_task INT NOT NULL REFERENCES task(id_task) ON DELETE CASCADE,
    id_student INT NOT NULL REFERENCES student(id_student) ON DELETE CASCADE,
    score_task INT NOT NULL,
    is_passed BOOLEAN NOT NULL,
    submitted_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    graded_at TIMESTAMPTZ,
    feedback TEXT,
    PRIMARY KEY (id_task, id_student)
);

CREATE INDEX idx_grade_task ON task_grade(id_task);
CREATE INDEX idx_grade_student ON task_grade(id_student);

INSERT INTO task_grade (id_task, id_student, score_task, is_passed, feedback)
VALUES 
    (1, 1, 90, TRUE, 'Хорошая работа!'),
    (1, 2, 65, TRUE, 'Можно улучшить форматирование кода.'),
    (2, 5, 40, FALSE, 'Требуется доработка. Недостаточно объяснений.');

-- 25. Архив курса
CREATE TABLE course_archive (
    id_course INT NOT NULL REFERENCES course(id_course) ON DELETE CASCADE,
    id_year INT NOT NULL REFERENCES academic_year(id_year) ON DELETE CASCADE,
    archived_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_course, id_year)
);

INSERT INTO course_archive (id_course, id_year)
VALUES 
    (1, 3),
    (2, 1);

-- 26. Личный кабинет
CREATE TABLE user_profile (
    id_user INT PRIMARY KEY REFERENCES users(id_user) ON DELETE CASCADE,
    contacts TEXT
);

INSERT INTO user_profile (id_user, contacts)
VALUES 
    (2, 'email: student1@mail.ru; phone: +71234567890'),
    (3, 'email: prepod1@gmail.com'),
    (5, 'telegram: @myname3');

-- 27. Настройки уведомлений
CREATE TABLE notification_settings (
    id_user INT PRIMARY KEY REFERENCES users(id_user) ON DELETE CASCADE,
    notification_new_task BOOLEAN DEFAULT TRUE,
    notification_new_test BOOLEAN DEFAULT TRUE,
    grade_notification BOOLEAN DEFAULT TRUE,
    deadline_reminder BOOLEAN DEFAULT TRUE
);

INSERT INTO notification_settings (id_user, notification_new_task, notification_new_test, grade_notification, deadline_reminder)
VALUES 
    (2, TRUE, TRUE, TRUE, TRUE),
    (3, FALSE, TRUE, TRUE, FALSE),
    (5, TRUE, FALSE, FALSE, TRUE);
