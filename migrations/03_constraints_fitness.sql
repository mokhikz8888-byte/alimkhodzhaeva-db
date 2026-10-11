-- НЕДЕЛЯ 3. ФИТНЕС-КЛУБ
-- Ограничения, внешние ключи и статус абонемента

-- 1. Создаём ENUM для статуса абонемента
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM pg_type t
        JOIN pg_namespace n ON n.oid = t.typnamespace
        WHERE t.typname = 'subscription_status'
          AND n.nspname = 'public'
    ) THEN
        CREATE TYPE public.subscription_status AS ENUM
        ('active', 'frozen', 'expired', 'cancelled');
    END IF;
END $$;

-- 2. Добавляем статус абонемента
ALTER TABLE public.subscriptions
ADD COLUMN IF NOT EXISTS status public.subscription_status
DEFAULT 'active';

-- 3. CHECK-ограничения

ALTER TABLE public.clients
ADD CONSTRAINT chk_clients_birth_date_not_future
CHECK (birth_date IS NULL OR birth_date <= CURRENT_DATE);

ALTER TABLE public.equipment
ADD CONSTRAINT chk_equipment_quantity_nonnegative
CHECK (quantity >= 0);

ALTER TABLE public.equipment
ADD CONSTRAINT chk_equipment_condition_status
CHECK (condition_status IN
('new', 'good', 'needs_repair', 'out_of_service'));

ALTER TABLE public.memberships
ADD CONSTRAINT chk_memberships_price_positive
CHECK (price > 0);

ALTER TABLE public.memberships
ADD CONSTRAINT chk_memberships_duration_positive
CHECK (duration_days > 0);

ALTER TABLE public.services
ADD CONSTRAINT chk_services_price_nonnegative
CHECK (price >= 0);

ALTER TABLE public.subscriptions
ADD CONSTRAINT chk_subscriptions_dates_valid
CHECK (end_date >= start_date);

ALTER TABLE public.payments
ADD CONSTRAINT chk_payments_amount_positive
CHECK (amount > 0);

ALTER TABLE public.payments
ADD CONSTRAINT chk_payments_method_allowed
CHECK (payment_method IN ('cash', 'card', 'transfer', 'online'));

-- 4. UNIQUE-ограничения

ALTER TABLE public.class_enrollments
ADD CONSTRAINT uq_class_enrollments_client_class
UNIQUE (client_id, class_id);

ALTER TABLE public.trainer_specializations
ADD CONSTRAINT uq_trainer_specializations_pair
UNIQUE (trainer_id, specialization_id);

-- 5. Внешние ключи

ALTER TABLE public.class_enrollments
ADD CONSTRAINT fk_enrollments_client
FOREIGN KEY (client_id)
REFERENCES public.clients(client_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE public.class_enrollments
ADD CONSTRAINT fk_enrollments_class
FOREIGN KEY (class_id)
REFERENCES public.group_classes(class_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE public.group_classes
ADD CONSTRAINT fk_group_classes_trainer
FOREIGN KEY (trainer_id)
REFERENCES public.trainers(trainer_id)
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.group_classes
ADD CONSTRAINT fk_group_classes_service
FOREIGN KEY (service_id)
REFERENCES public.services(service_id)
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.payments
ADD CONSTRAINT fk_payments_client
FOREIGN KEY (client_id)
REFERENCES public.clients(client_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

ALTER TABLE public.subscriptions
ADD CONSTRAINT fk_subscriptions_client
FOREIGN KEY (client_id)
REFERENCES public.clients(client_id)
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.subscriptions
ADD CONSTRAINT fk_subscriptions_membership
FOREIGN KEY (membership_id)
REFERENCES public.memberships(membership_id)
ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE public.trainer_specializations
ADD CONSTRAINT fk_trainer_specializations_trainer
FOREIGN KEY (trainer_id)
REFERENCES public.trainers(trainer_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE public.trainer_specializations
ADD CONSTRAINT fk_trainer_specializations_specialization
FOREIGN KEY (specialization_id)
REFERENCES public.specializations(specialization_id)
ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE public.visits
ADD CONSTRAINT fk_visits_client
FOREIGN KEY (client_id)
REFERENCES public.clients(client_id)
ON DELETE RESTRICT ON UPDATE CASCADE;

-- 6. Обоснование ON DELETE для трёх внешних ключей

COMMENT ON CONSTRAINT fk_enrollments_client
ON public.class_enrollments IS
'CASCADE: запись на занятие удаляется вместе с клиентом, так как зависит от него.';

COMMENT ON CONSTRAINT fk_payments_client
ON public.payments IS
'RESTRICT: нельзя удалить клиента, если у него есть платежи; это сохраняет историю оплат.';

COMMENT ON CONSTRAINT fk_group_classes_trainer
ON public.group_classes IS
'SET NULL: при удалении тренера занятие сохраняется, а ссылка на тренера очищается.';
