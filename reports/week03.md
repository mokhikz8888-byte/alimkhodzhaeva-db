# Week 03 — Constraints and Negative Tests
## Project: Fitness Club

### 1. Foreign Keys

Foreign keys connect related tables and preserve referential integrity.

- `class_enrollments.client_id` → `clients.client_id`: `ON DELETE CASCADE` — enrollment depends on the client.
- `class_enrollments.class_id` → `group_classes.class_id`: `ON DELETE CASCADE` — enrollment is removed with the class.
- `group_classes.trainer_id` → `trainers.trainer_id`: `ON DELETE SET NULL` — the class remains if the trainer is deleted.
- `group_classes.service_id` → `services.service_id`: `ON DELETE SET NULL`.
- `payments.client_id` → `clients.client_id`: `ON DELETE RESTRICT` — payment history is protected.
- `subscriptions.client_id` → `clients.client_id`: `ON DELETE SET NULL`.
- `subscriptions.membership_id` → `memberships.membership_id`: `ON DELETE SET NULL`.
- `trainer_specializations.trainer_id` → `trainers.trainer_id`: `ON DELETE CASCADE`.
- `trainer_specializations.specialization_id` → `specializations.specialization_id`: `ON DELETE CASCADE`.
- `visits.client_id` → `clients.client_id`: `ON DELETE RESTRICT`.

### 2. CHECK Constraints

- Client birth date cannot be in the future.
- Equipment quantity cannot be negative.
- Equipment condition must match an allowed value, including `Хорошее`.
- Membership price must be positive.
- Membership duration must be positive.
- Service price cannot be negative.
- Subscription end date cannot precede its start date.
- Payment amount must be positive.
- Payment method must be one of `cash`, `card`, `transfer`, `online`.

### 3. UNIQUE Constraints and ENUM

- `uq_class_enrollments_client_class` prevents duplicate client/class pairs.
- `uq_trainer_specializations_pair` prevents duplicate trainer/specialization pairs.
- `subscription_status` ENUM contains `active`, `frozen`, `expired`, and `cancelled`.

### 4. Negative Tests

| Test | Expected SQLSTATE | Actual result |
|---|---|---|
| Negative membership price | 23514 | Record the actual result from pgAdmin |
| Invalid subscription dates | 23514 | Record the actual result from pgAdmin |
| Negative payment amount | 23514 | Record the actual result from pgAdmin |
| Invalid payment method `crypto` | 23514 | Failed as expected: `chk_payments_method_allowed` |
| Duplicate class enrollment | 23505 | Failed as expected: `class_enrollments_pkey` |

### 5. Conclusion

The database schema includes foreign keys, CHECK constraints, UNIQUE constraints, and an ENUM type. Negative tests demonstrated that PostgreSQL rejects invalid payment methods and duplicate enrollment records. Actual output for each test should be documented based on the pgAdmin results.
