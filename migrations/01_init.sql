-- Проект: Фитнес-клуб
-- Миграция 01: создание таблиц и начальных данных

-- 1. Клиенты
CREATE TABLE clients (
    client_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    birth_date DATE
);

-- 2. Тренеры
CREATE TABLE trainers (
    trainer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100),
    phone VARCHAR(20)
);

-- 3. Справочник абонементов
CREATE TABLE memberships (
    membership_id SERIAL PRIMARY KEY,
    membership_name VARCHAR(100) NOT NULL,
    price NUMERIC(10, 2) NOT NULL,
    duration_days INTEGER NOT NULL
);

-- 4. Оформленные абонементы
CREATE TABLE subscriptions (
    subscription_id SERIAL PRIMARY KEY,
    client_id INTEGER REFERENCES clients(client_id),
    membership_id INTEGER REFERENCES memberships(membership_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL
);

-- 5. Справочник услуг
CREATE TABLE services (
    service_id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) NOT NULL UNIQUE,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0),
    description TEXT
);

-- 6. Справочник оборудования
CREATE TABLE equipment (
    equipment_id SERIAL PRIMARY KEY,
    equipment_name VARCHAR(100) NOT NULL UNIQUE,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    condition_status VARCHAR(30) NOT NULL
);

-- 7. Посещения: большая таблица фактов
CREATE TABLE visits (
    visit_id BIGSERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES clients(client_id),
    visit_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    purpose TEXT
);

-- 8. Групповые занятия
CREATE TABLE group_classes (
    class_id SERIAL PRIMARY KEY,
    class_name VARCHAR(100) NOT NULL,
    trainer_id INTEGER REFERENCES trainers(trainer_id),
    service_id INTEGER REFERENCES services(service_id),
    class_time TIMESTAMP NOT NULL,
    description TEXT
);

-- 9. Записи клиентов на групповые занятия
CREATE TABLE class_enrollments (
    client_id INTEGER REFERENCES clients(client_id),
    class_id INTEGER REFERENCES group_classes(class_id),
    enrollment_date DATE NOT NULL DEFAULT CURRENT_DATE,
    PRIMARY KEY (client_id, class_id)
);

-- 10. Справочник специализаций
CREATE TABLE specializations (
    specialization_id SERIAL PRIMARY KEY,
    specialization_name VARCHAR(100) NOT NULL UNIQUE
);

-- 11. Связь тренеров со специализациями
CREATE TABLE trainer_specializations (
    trainer_id INTEGER REFERENCES trainers(trainer_id),
    specialization_id INTEGER REFERENCES specializations(specialization_id),
    PRIMARY KEY (trainer_id, specialization_id)
);

-- 12. Платежи
CREATE TABLE payments (
    payment_id BIGSERIAL PRIMARY KEY,
    client_id INTEGER NOT NULL REFERENCES clients(client_id),
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_method VARCHAR(30) NOT NULL,
    comment TEXT
);

-- Начальные данные: клиенты
INSERT INTO clients (full_name, phone, birth_date) VALUES
('Алия Садыкова', '+77011234567', '2002-05-14'),
('Данияр Ахметов', '+77021234567', '2000-09-20'),
('Мадина Ержанова', '+77031234567', '2003-01-11');

-- Начальные данные: тренеры
INSERT INTO trainers (full_name, specialization, phone) VALUES
('Арман Касымов', 'Силовые тренировки', '+77041234567'),
('Диана Омарова', 'Фитнес и растяжка', '+77051234567');

-- Справочник абонементов: 10 записей
INSERT INTO memberships (membership_name, price, duration_days) VALUES
('Разовое посещение', 3000, 1),
('На 1 неделю', 7000, 7),
('На 1 месяц', 15000, 30),
('На 2 месяца', 28000, 60),
('На 3 месяца', 40000, 90),
('На 6 месяцев', 75000, 180),
('На 9 месяцев', 100000, 270),
('На 12 месяцев', 120000, 365),
('Студенческий на 1 месяц', 10000, 30),
('Утренний на 1 месяц', 12000, 30);

-- Справочник услуг: 10 записей
INSERT INTO services (service_name, price, description) VALUES
('Тренажёрный зал', 3000, 'Самостоятельные тренировки на тренажёрах'),
('Персональная тренировка', 7000, 'Индивидуальное занятие с тренером'),
('Групповая йога', 4000, 'Занятия йогой в группе'),
('Пилатес', 4500, 'Упражнения для гибкости и укрепления мышц'),
('Стретчинг', 3500, 'Занятия на растяжку мышц'),
('Кардиотренировка', 4000, 'Тренировка для развития выносливости'),
('Силовая тренировка', 5000, 'Упражнения для развития силы'),
('Функциональная тренировка', 5000, 'Комплекс упражнений для всего тела'),
('Бокс', 6000, 'Тренировка по основам бокса'),
('Консультация тренера', 2500, 'Консультация по плану тренировок');

-- Справочник оборудования: 10 записей
INSERT INTO equipment (equipment_name, quantity, condition_status) VALUES
('Беговая дорожка', 5, 'Хорошее'),
('Велотренажёр', 4, 'Хорошее'),
('Эллиптический тренажёр', 3, 'Хорошее'),
('Гантели', 30, 'Хорошее'),
('Штанга', 8, 'Хорошее'),
('Силовая скамья', 6, 'Хорошее'),
('Коврик для йоги', 20, 'Хорошее'),
('Фитнес-мяч', 10, 'Хорошее'),
('Скакалка', 15, 'Хорошее'),
('Боксёрская груша', 3, 'Хорошее');

-- Справочник специализаций: 10 записей
INSERT INTO specializations (specialization_name) VALUES
('Силовые тренировки'),
('Фитнес'),
('Растяжка'),
('Йога'),
('Пилатес'),
('Кардиотренировки'),
('Бокс'),
('Функциональный тренинг'),
('Похудение'),
('Набор мышечной массы');

-- Связи тренеров со специализациями
INSERT INTO trainer_specializations (trainer_id, specialization_id)
SELECT t.trainer_id, s.specialization_id
FROM trainers t
JOIN specializations s
    ON (t.full_name = 'Арман Касымов'
        AND s.specialization_name IN (
            'Силовые тренировки',
            'Набор мышечной массы'
        ))
    OR (t.full_name = 'Диана Омарова'
        AND s.specialization_name IN (
            'Фитнес', 'Растяжка', 'Пилатес'
        ));

-- Оформленные абонементы
INSERT INTO subscriptions
    (client_id, membership_id, start_date, end_date)
SELECT c.client_id, m.membership_id, v.start_date, v.end_date
FROM (VALUES
    ('Алия Садыкова', 'На 1 месяц', DATE '2026-10-01', DATE '2026-10-31'),
    ('Данияр Ахметов', 'На 3 месяца', DATE '2026-10-05', DATE '2027-01-03'),
    ('Мадина Ержанова', 'На 12 месяцев', DATE '2026-10-10', DATE '2027-10-09')
) AS v(client_name, membership_name, start_date, end_date)
JOIN clients c ON c.full_name = v.client_name
JOIN memberships m ON m.membership_name = v.membership_name;

-- Групповые занятия
INSERT INTO group_classes
    (class_name, trainer_id, service_id, class_time, description)
SELECT v.class_name, t.trainer_id, s.service_id,
       v.class_time::TIMESTAMP, v.description
FROM (VALUES
    ('Утренняя йога', 'Диана Омарова', 'Групповая йога',
     '2026-10-12 09:00', 'Утренняя практика для гибкости'),
    ('Растяжка для начинающих', 'Диана Омарова', 'Стретчинг',
     '2026-10-12 11:00', 'Занятие для развития гибкости'),
    ('Силовая тренировка', 'Арман Касымов', 'Силовая тренировка',
     '2026-10-12 18:00', 'Тренировка основных групп мышц'),
    ('Функциональный тренинг', 'Арман Касымов', 'Функциональная тренировка',
     '2026-10-13 18:00', 'Комплекс упражнений на выносливость'),
    ('Пилатес', 'Диана Омарова', 'Пилатес',
     '2026-10-13 10:00', 'Упражнения для осанки и контроля тела')
) AS v(class_name, trainer_name, service_name, class_time, description)
JOIN trainers t ON t.full_name = v.trainer_name
JOIN services s ON s.service_name = v.service_name;

-- Записи клиентов на занятия
INSERT INTO class_enrollments (client_id, class_id, enrollment_date)
SELECT c.client_id, gc.class_id, DATE '2026-10-11'
FROM (VALUES
    ('Алия Садыкова', 'Утренняя йога'),
    ('Алия Садыкова', 'Пилатес'),
    ('Данияр Ахметов', 'Силовая тренировка'),
    ('Данияр Ахметов', 'Функциональный тренинг'),
    ('Мадина Ержанова', 'Растяжка для начинающих'),
    ('Мадина Ержанова', 'Пилатес')
) AS v(client_name, class_name)
JOIN clients c ON c.full_name = v.client_name
JOIN group_classes gc ON gc.class_name = v.class_name;

-- Начальные данные: платежи
INSERT INTO payments (client_id, amount, payment_date, payment_method, comment)
VALUES
(1, 15000, '2026-10-01 09:00', 'Карта', 'Оплата месячного абонемента'),
(2, 40000, '2026-10-05 18:00', 'Перевод', 'Оплата абонемента на три месяца'),
(3, 120000, '2026-10-10 10:00', 'Карта', 'Оплата годового абонемента');

-- 300 000 тестовых посещений
INSERT INTO visits (client_id, visit_time, purpose)
SELECT
    ((g - 1) % 3 + 1)::INTEGER,
    TIMESTAMP '2025-01-01 00:00:00' + g * INTERVAL '1 minute',
    CASE (g % 5)
        WHEN 0 THEN 'Кардиотренировка для развития выносливости'
        WHEN 1 THEN 'Силовая тренировка для укрепления мышц'
        WHEN 2 THEN 'Растяжка для улучшения гибкости'
        WHEN 3 THEN 'Тренировка на беговой дорожке'
        ELSE 'Занятие для поддержания физической формы'
    END
FROM generate_series(1::BIGINT, 300000::BIGINT) AS series(g);

-- Индексы для поиска и сортировки посещений
CREATE INDEX idx_visits_visit_time
ON visits (visit_time);

CREATE INDEX idx_visits_purpose_search
ON visits USING GIN (
    to_tsvector('simple', COALESCE(purpose, ''))
);
