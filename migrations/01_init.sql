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
