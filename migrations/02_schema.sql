-- Проект: Городской пассажирский транспорт
-- Неделя 2: схема базы данных
-- Внешние ключи будут добавлены на следующем этапе.

-- 1. Автобусные парки
CREATE TABLE depots (
    depot_id SERIAL PRIMARY KEY,
    depot_name VARCHAR(100) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(200)
);

COMMENT ON TABLE depots IS 'Автобусные парки транспортной организации';
COMMENT ON COLUMN depots.depot_id IS 'Уникальный идентификатор парка';
COMMENT ON COLUMN depots.depot_name IS 'Название автобусного парка';
COMMENT ON COLUMN depots.city IS 'Город расположения парка';
COMMENT ON COLUMN depots.address IS 'Адрес автобусного парка';

-- 2. Маршруты
CREATE TABLE routes (
    route_id SERIAL PRIMARY KEY,
    route_no INTEGER NOT NULL,
    city VARCHAR(100) NOT NULL,
    route_length_km NUMERIC(6,2) NOT NULL
);

COMMENT ON TABLE routes IS 'Маршруты городского транспорта';
COMMENT ON COLUMN routes.route_id IS 'Уникальный идентификатор маршрута';
COMMENT ON COLUMN routes.route_no IS 'Номер маршрута';
COMMENT ON COLUMN routes.city IS 'Город обслуживания маршрута';
COMMENT ON COLUMN routes.route_length_km IS 'Длина маршрута в километрах';

-- 3. Остановки
CREATE TABLE stops (
    stop_id SERIAL PRIMARY KEY,
    stop_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    latitude NUMERIC(9,6),
    longitude NUMERIC(9,6)
);

COMMENT ON TABLE stops IS 'Справочник остановок';
COMMENT ON COLUMN stops.stop_id IS 'Уникальный идентификатор остановки';
COMMENT ON COLUMN stops.stop_name IS 'Название остановки';
COMMENT ON COLUMN stops.city IS 'Город расположения остановки';
COMMENT ON COLUMN stops.latitude IS 'Географическая широта остановки';
COMMENT ON COLUMN stops.longitude IS 'Географическая долгота остановки';

-- 4. Остановки маршрутов: связь многие-ко-многим
CREATE TABLE route_stops (
    route_stop_id SERIAL PRIMARY KEY,
    route_id INTEGER NOT NULL,
    stop_id INTEGER NOT NULL,
    stop_order INTEGER NOT NULL,
    distance_from_start_km NUMERIC(6,2)
);

COMMENT ON TABLE route_stops IS 'Остановки, входящие в маршруты, и их порядок';
COMMENT ON COLUMN route_stops.route_stop_id IS 'Уникальный идентификатор связи';
COMMENT ON COLUMN route_stops.route_id IS 'Идентификатор маршрута';
COMMENT ON COLUMN route_stops.stop_id IS 'Идентификатор остановки';
COMMENT ON COLUMN route_stops.stop_order IS 'Порядковый номер остановки на маршруте';
COMMENT ON COLUMN route_stops.distance_from_start_km IS 'Расстояние от начала маршрута в километрах';

-- 5. Водители
CREATE TABLE drivers (
    driver_id SERIAL PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    middle_name VARCHAR(80),
    phone VARCHAR(20),
    license_category VARCHAR(10),
    driver_since SMALLINT
);

COMMENT ON TABLE drivers IS 'Сведения о водителях';
COMMENT ON COLUMN drivers.driver_id IS 'Уникальный идентификатор водителя';
COMMENT ON COLUMN drivers.first_name IS 'Имя водителя';
COMMENT ON COLUMN drivers.last_name IS 'Фамилия водителя';
COMMENT ON COLUMN drivers.middle_name IS 'Отчество водителя';
COMMENT ON COLUMN drivers.phone IS 'Контактный телефон водителя';
COMMENT ON COLUMN drivers.license_category IS 'Категория водительского удостоверения';
COMMENT ON COLUMN drivers.driver_since IS 'Год начала работы водителем';

-- 6. Модели автобусов
CREATE TABLE bus_models (
    model_id SERIAL PRIMARY KEY,
    manufacturer VARCHAR(80) NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    capacity INTEGER NOT NULL
);

COMMENT ON TABLE bus_models IS 'Справочник моделей автобусов';
COMMENT ON COLUMN bus_models.model_id IS 'Уникальный идентификатор модели';
COMMENT ON COLUMN bus_models.manufacturer IS 'Производитель автобуса';
COMMENT ON COLUMN bus_models.model_name IS 'Название модели автобуса';
COMMENT ON COLUMN bus_models.capacity IS 'Пассажировместимость автобуса';

-- 7. Автобусы
CREATE TABLE buses (
    bus_id SERIAL PRIMARY KEY,
    plate VARCHAR(20) NOT NULL UNIQUE,
    model_id INTEGER NOT NULL,
    vehicle_year SMALLINT NOT NULL,
    in_service BOOLEAN NOT NULL DEFAULT TRUE
);

COMMENT ON TABLE buses IS 'Автобусы транспортной организации';
COMMENT ON COLUMN buses.bus_id IS 'Внутренний идентификатор автобуса';
COMMENT ON COLUMN buses.plate IS 'Государственный регистрационный номер';
COMMENT ON COLUMN buses.model_id IS 'Идентификатор модели автобуса';
COMMENT ON COLUMN buses.vehicle_year IS 'Год выпуска автобуса';
COMMENT ON COLUMN buses.in_service IS 'Признак эксплуатации автобуса';

-- 8. Рейсы
CREATE TABLE trips (
    trip_id BIGSERIAL PRIMARY KEY,
    route_id INTEGER NOT NULL,
    trip_date DATE NOT NULL,
    departure_time TIME NOT NULL,
    arrival_time TIME NOT NULL,
    passengers_count INTEGER NOT NULL DEFAULT 0,
    revenue_kzt NUMERIC(12,2) NOT NULL DEFAULT 0
);

COMMENT ON TABLE trips IS 'Запланированные и выполненные рейсы';
COMMENT ON COLUMN trips.trip_id IS 'Уникальный идентификатор рейса';
COMMENT ON COLUMN trips.route_id IS 'Идентификатор маршрута';
COMMENT ON COLUMN trips.trip_date IS 'Дата выполнения рейса';
COMMENT ON COLUMN trips.departure_time IS 'Время отправления';
COMMENT ON COLUMN trips.arrival_time IS 'Время прибытия';
COMMENT ON COLUMN trips.passengers_count IS 'Количество перевезённых пассажиров';
COMMENT ON COLUMN trips.revenue_kzt IS 'Выручка за рейс в тенге';

-- 9. Назначение водителей на рейсы
CREATE TABLE trip_drivers (
    trip_driver_id BIGSERIAL PRIMARY KEY,
    trip_id BIGINT NOT NULL,
    driver_id INTEGER NOT NULL,
    assignment_role VARCHAR(30) NOT NULL DEFAULT 'Основной'
);

COMMENT ON TABLE trip_drivers IS 'Назначения водителей на рейсы';
COMMENT ON COLUMN trip_drivers.trip_driver_id IS 'Уникальный идентификатор назначения';
COMMENT ON COLUMN trip_drivers.trip_id IS 'Идентификатор рейса';
COMMENT ON COLUMN trip_drivers.driver_id IS 'Идентификатор водителя';
COMMENT ON COLUMN trip_drivers.assignment_role IS 'Роль водителя на рейсе';

-- 10. Назначение автобусов на рейсы
CREATE TABLE trip_buses (
    trip_bus_id BIGSERIAL PRIMARY KEY,
    trip_id BIGINT NOT NULL,
    bus_id INTEGER NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE trip_buses IS 'Назначения автобусов на рейсы';
COMMENT ON COLUMN trip_buses.trip_bus_id IS 'Уникальный идентификатор назначения';
COMMENT ON COLUMN trip_buses.trip_id IS 'Идентификатор рейса';
COMMENT ON COLUMN trip_buses.bus_id IS 'Идентификатор автобуса';
COMMENT ON COLUMN trip_buses.assigned_at IS 'Дата и время назначения автобуса';

-- 11. Пассажиры
CREATE TABLE passengers (
    passenger_id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(80) NOT NULL,
    last_name VARCHAR(80) NOT NULL,
    phone VARCHAR(20)
);

COMMENT ON TABLE passengers IS 'Сведения о зарегистрированных пассажирах';
COMMENT ON COLUMN passengers.passenger_id IS 'Уникальный идентификатор пассажира';
COMMENT ON COLUMN passengers.first_name IS 'Имя пассажира';
COMMENT ON COLUMN passengers.last_name IS 'Фамилия пассажира';
COMMENT ON COLUMN passengers.phone IS 'Контактный телефон пассажира';

-- 12. Билеты
CREATE TABLE tickets (
    ticket_id BIGSERIAL PRIMARY KEY,
    passenger_id BIGINT NOT NULL,
    trip_id BIGINT NOT NULL,
    seat_number VARCHAR(10),
    fare_kzt NUMERIC(10,2) NOT NULL
);

COMMENT ON TABLE tickets IS 'Билеты пассажиров на рейсы';
COMMENT ON COLUMN tickets.ticket_id IS 'Уникальный идентификатор билета';
COMMENT ON COLUMN tickets.passenger_id IS 'Идентификатор пассажира';
COMMENT ON COLUMN tickets.trip_id IS 'Идентификатор рейса';
COMMENT ON COLUMN tickets.seat_number IS 'Номер места, если оно предусмотрено';
COMMENT ON COLUMN tickets.fare_kzt IS 'Стоимость билета в тенге';

-- 13. Платежи
CREATE TABLE payments (
    payment_id BIGSERIAL PRIMARY KEY,
    ticket_id BIGINT NOT NULL,
    payment_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    amount_kzt NUMERIC(10,2) NOT NULL,
    payment_method VARCHAR(30) NOT NULL
);

COMMENT ON TABLE payments IS 'Оплата билетов';
COMMENT ON COLUMN payments.payment_id IS 'Уникальный идентификатор платежа';
COMMENT ON COLUMN payments.ticket_id IS 'Идентификатор оплачиваемого билета';
COMMENT ON COLUMN payments.payment_date IS 'Дата и время оплаты';
COMMENT ON COLUMN payments.amount_kzt IS 'Сумма платежа в тенге';
COMMENT ON COLUMN payments.payment_method IS 'Способ оплаты';

-- 14. Техническое обслуживание
CREATE TABLE maintenance (
    maintenance_id BIGSERIAL PRIMARY KEY,
    bus_id INTEGER NOT NULL,
    maintenance_date DATE NOT NULL,
    maintenance_type VARCHAR(100) NOT NULL,
    description TEXT,
    cost_kzt NUMERIC(12,2) DEFAULT 0
);

COMMENT ON TABLE maintenance IS 'История технического обслуживания автобусов';
COMMENT ON COLUMN maintenance.maintenance_id IS 'Уникальный идентификатор обслуживания';
COMMENT ON COLUMN maintenance.bus_id IS 'Идентификатор обслуживаемого автобуса';
COMMENT ON COLUMN maintenance.maintenance_date IS 'Дата обслуживания';
COMMENT ON COLUMN maintenance.maintenance_type IS 'Тип технических работ';
COMMENT ON COLUMN maintenance.description IS 'Подробное описание выполненных работ';
COMMENT ON COLUMN maintenance.cost_kzt IS 'Стоимость обслуживания в тенге';

-- 15. Закрепление автобусов за парками
CREATE TABLE depot_buses (
    depot_bus_id BIGSERIAL PRIMARY KEY,
    depot_id INTEGER NOT NULL,
    bus_id INTEGER NOT NULL,
    assigned_from DATE NOT NULL,
    assigned_to DATE
);

COMMENT ON TABLE depot_buses IS 'История закрепления автобусов за парками';
COMMENT ON COLUMN depot_buses.depot_bus_id IS 'Уникальный идентификатор закрепления';
COMMENT ON COLUMN depot_buses.depot_id IS 'Идентификатор автобусного парка';
COMMENT ON COLUMN depot_buses.bus_id IS 'Идентификатор автобуса';
COMMENT ON COLUMN depot_buses.assigned_from IS 'Дата начала закрепления';
COMMENT ON COLUMN depot_buses.assigned_to IS 'Дата окончания закрепления, если оно завершено';
