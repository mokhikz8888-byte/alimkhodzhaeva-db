
-- Неделя 3. Ограничения целостности
-- Проект: Городской пассажирский транспорт

-- 1. ENUM-типы для статусов
CREATE TYPE trip_status AS ENUM (
    'scheduled',
    'in_progress',
    'completed',
    'cancelled'
);

-- В схеме пока нет таблицы обращений.
-- Тип подготовлен для использования при её создании.
CREATE TYPE inquiry_status AS ENUM (
    'new',
    'in_progress',
    'resolved',
    'rejected'
);

ALTER TABLE trips
ADD COLUMN status trip_status NOT NULL DEFAULT 'scheduled';

-- 2. Домен казахстанского номера телефона
CREATE DOMAIN phone_kz AS TEXT
CHECK (
    VALUE ~ '^\+7[0-9]{10}$'
);

-- Перед применением домена существующие телефоны
-- должны иметь формат +7 и ещё 10 цифр.
ALTER TABLE drivers
ALTER COLUMN phone TYPE phone_kz
USING phone::TEXT::phone_kz;

ALTER TABLE passengers
ALTER COLUMN phone TYPE phone_kz
USING phone::TEXT::phone_kz;

-- 3. Внешние ключи
-- Парк нельзя удалить, пока за ним закреплены автобусы.
ALTER TABLE depot_buses
ADD CONSTRAINT fk_depot_buses_depot
FOREIGN KEY (depot_id)
REFERENCES depots(depot_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- При удалении автобуса удаляем его историю назначений,
-- обслуживания и закрепления за парком.
ALTER TABLE depot_buses
ADD CONSTRAINT fk_depot_buses_bus
FOREIGN KEY (bus_id)
REFERENCES buses(bus_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE buses
ADD CONSTRAINT fk_buses_model
FOREIGN KEY (model_id)
REFERENCES bus_models(model_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE route_stops
ADD CONSTRAINT fk_route_stops_route
FOREIGN KEY (route_id)
REFERENCES routes(route_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE route_stops
ADD CONSTRAINT fk_route_stops_stop
FOREIGN KEY (stop_id)
REFERENCES stops(stop_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE trips
ADD CONSTRAINT fk_trips_route
FOREIGN KEY (route_id)
REFERENCES routes(route_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE trip_drivers
ADD CONSTRAINT fk_trip_drivers_trip
FOREIGN KEY (trip_id)
REFERENCES trips(trip_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE trip_drivers
ADD CONSTRAINT fk_trip_drivers_driver
FOREIGN KEY (driver_id)
REFERENCES drivers(driver_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE trip_buses
ADD CONSTRAINT fk_trip_buses_trip
FOREIGN KEY (trip_id)
REFERENCES trips(trip_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE trip_buses
ADD CONSTRAINT fk_trip_buses_bus
FOREIGN KEY (bus_id)
REFERENCES buses(bus_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE tickets
ADD CONSTRAINT fk_tickets_passenger
FOREIGN KEY (passenger_id)
REFERENCES passengers(passenger_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE tickets
ADD CONSTRAINT fk_tickets_trip
FOREIGN KEY (trip_id)
REFERENCES trips(trip_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE payments
ADD CONSTRAINT fk_payments_ticket
FOREIGN KEY (ticket_id)
REFERENCES tickets(ticket_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE maintenance
ADD CONSTRAINT fk_maintenance_bus
FOREIGN KEY (bus_id)
REFERENCES buses(bus_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- 4. Ограничения CHECK
ALTER TABLE routes
ADD CONSTRAINT chk_routes_number_positive
CHECK (route_no > 0);

ALTER TABLE routes
ADD CONSTRAINT chk_routes_length_positive
CHECK (route_length_km > 0);

ALTER TABLE stops
ADD CONSTRAINT chk_stops_latitude
CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90);

ALTER TABLE stops
ADD CONSTRAINT chk_stops_longitude
CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180);

ALTER TABLE route_stops
ADD CONSTRAINT chk_route_stops_order_positive
CHECK (stop_order >= 1);

ALTER TABLE route_stops
ADD CONSTRAINT chk_route_stops_distance_nonnegative
CHECK (
    distance_from_start_km IS NULL
    OR distance_from_start_km >= 0
);

ALTER TABLE bus_models
ADD CONSTRAINT chk_bus_models_capacity_positive
CHECK (capacity > 0);

ALTER TABLE buses
ADD CONSTRAINT chk_buses_year
CHECK (vehicle_year BETWEEN 1950 AND 2100);

ALTER TABLE trips
ADD CONSTRAINT chk_trips_arrival_after_departure
CHECK (arrival_time > departure_time);

ALTER TABLE trips
ADD CONSTRAINT chk_trips_passengers_nonnegative
CHECK (passengers_count >= 0);

ALTER TABLE trips
ADD CONSTRAINT chk_trips_revenue_nonnegative
CHECK (revenue_kzt >= 0);

ALTER TABLE tickets
ADD CONSTRAINT chk_tickets_fare_nonnegative
CHECK (fare_kzt >= 0);

ALTER TABLE payments
ADD CONSTRAINT chk_payments_amount_nonnegative
CHECK (amount_kzt >= 0);

ALTER TABLE maintenance
ADD CONSTRAINT chk_maintenance_cost_nonnegative
CHECK (cost_kzt IS NULL OR cost_kzt >= 0);

ALTER TABLE depot_buses
ADD CONSTRAINT chk_depot_buses_dates
CHECK (assigned_to IS NULL OR assigned_to >= assigned_from);

-- 5. Составные UNIQUE
-- На маршруте не может быть двух остановок с одним номером.
ALTER TABLE route_stops
ADD CONSTRAINT uq_route_stops_route_order
UNIQUE (route_id, stop_order);

-- Один автобус не назначается одному рейсу дважды.
ALTER TABLE trip_buses
ADD CONSTRAINT uq_trip_buses_trip_bus
UNIQUE (trip_id, bus_id);

-- Один пассажир не может получить несколько билетов
-- на один и тот же рейс.
ALTER TABLE tickets
ADD CONSTRAINT uq_tickets_passenger_trip
UNIQUE (passenger_id, trip_id);

-- Одно место на одном рейсе нельзя продать повторно.
CREATE UNIQUE INDEX uq_tickets_trip_seat
ON tickets (trip_id, seat_number)
WHERE seat_number IS NOT NULL;

-- 6. Комментарии с обоснованием поведения
COMMENT ON CONSTRAINT fk_depot_buses_depot ON depot_buses
IS 'RESTRICT: нельзя удалить парк, пока к нему привязаны автобусы';

COMMENT ON CONSTRAINT fk_trip_drivers_trip ON trip_drivers
IS 'CASCADE: назначения водителей удаляются вместе с рейсом';

COMMENT ON CONSTRAINT fk_trip_buses_trip ON trip_buses
IS 'CASCADE: назначения автобусов удаляются вместе с рейсом';

COMMENT ON CONSTRAINT fk_tickets_trip ON tickets
IS 'RESTRICT: нельзя удалить рейс, пока существуют билеты';

COMMENT ON CONSTRAINT fk_payments_ticket ON payments
IS 'RESTRICT: нельзя удалить билет, пока существуют платежи';

