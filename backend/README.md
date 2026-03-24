# Smart Dental Clinic Backend

Node.js + Express + Supabase backend for patient-facing dental clinic workflows.

## Setup

1. Copy `.env.example` to `.env` and add values.
2. Run SQL in `sql/schema.sql` in Supabase SQL editor.
3. Install and run:

```bash
npm install
npm run dev
```

## Auth

- `POST /auth/login`

Body:
```json
{
  "email": "patient@example.com",
  "password": "password"
}
```

Use returned `access_token` as `Authorization: Bearer <token>`.

## Endpoints

- `GET /patient/profile`
- `GET /patient/dashboard`
- `GET /doctors`
- `GET /doctors/:id`
- `POST /appointments/book`
- `GET /appointments/my`
- `GET /payments/my`
- `GET /reports/my`

## Notes

- Appointment booking prevents same doctor-slot conflicts.
- Booking only allows future date/time.
- Payment `remaining_amount` is generated as `total_amount - paid_amount`.
- Protected routes are scoped to the authenticated patient ID.
