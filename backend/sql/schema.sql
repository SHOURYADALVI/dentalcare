-- Smart Dental Clinic Management System schema (Supabase PostgreSQL)
create extension if not exists "pgcrypto";

create table if not exists public.patients (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  age integer not null check (age > 0),
  phone text not null,
  email text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists public.doctors (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  qualification text not null,
  phone text not null,
  email text not null unique,
  clinic_address text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.appointments (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete restrict,
  date date not null,
  time time not null,
  consultation_fee numeric(10,2) not null check (consultation_fee >= 0),
  status text not null default 'Scheduled' check (status in ('Scheduled', 'Completed', 'Cancelled')),
  created_at timestamptz not null default now()
);

create table if not exists public.payments (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null unique references public.patients(id) on delete cascade,
  total_amount numeric(10,2) not null default 0 check (total_amount >= 0),
  paid_amount numeric(10,2) not null default 0 check (paid_amount >= 0),
  remaining_amount numeric(10,2) generated always as (greatest(total_amount - paid_amount, 0)) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint payment_paid_lte_total check (paid_amount <= total_amount)
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  patient_id uuid not null references public.patients(id) on delete cascade,
  doctor_id uuid not null references public.doctors(id) on delete restrict,
  diagnosis text not null,
  treatment text not null,
  medicines text not null,
  precautions text not null,
  created_at timestamptz not null default now()
);

create index if not exists idx_appointments_patient_date on public.appointments(patient_id, date);
create index if not exists idx_appointments_doctor_slot on public.appointments(doctor_id, date, time);
create index if not exists idx_reports_patient_created on public.reports(patient_id, created_at desc);
create index if not exists idx_payments_patient on public.payments(patient_id);

create unique index if not exists ux_doctor_slot_active
on public.appointments(doctor_id, date, time)
where status <> 'Cancelled';

create or replace function public.update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists trg_payments_updated_at on public.payments;
create trigger trg_payments_updated_at
before update on public.payments
for each row execute function public.update_updated_at_column();

-- Optional RLS (recommended with Supabase)
alter table public.patients enable row level security;
alter table public.appointments enable row level security;
alter table public.payments enable row level security;
alter table public.reports enable row level security;

drop policy if exists "patients can view own profile" on public.patients;
create policy "patients can view own profile" on public.patients
for select using (auth.uid() = id);

drop policy if exists "patients can view own appointments" on public.appointments;
create policy "patients can view own appointments" on public.appointments
for select using (auth.uid() = patient_id);

drop policy if exists "patients can book own appointments" on public.appointments;
create policy "patients can book own appointments" on public.appointments
for insert with check (auth.uid() = patient_id);

drop policy if exists "patients can view own payments" on public.payments;
create policy "patients can view own payments" on public.payments
for select using (auth.uid() = patient_id);

drop policy if exists "patients can view own reports" on public.reports;
create policy "patients can view own reports" on public.reports
for select using (auth.uid() = patient_id);
