import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';

import authRoutes from './modules/auth/auth.routes.js';
import patientRoutes from './modules/patients/patients.routes.js';
import doctorRoutes from './modules/doctors/doctors.routes.js';
import appointmentRoutes from './modules/appointments/appointments.routes.js';
import paymentRoutes from './modules/payments/payments.routes.js';
import reportRoutes from './modules/reports/reports.routes.js';
import { protect } from './middleware/authMiddleware.js';
import { errorHandler, notFound } from './middleware/errorHandler.js';

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

app.get('/health', (_req, res) => {
  res.status(200).json({ success: true, message: 'API is healthy' });
});

app.use('/auth', authRoutes);

app.use(protect);
app.use('/patient', patientRoutes);
app.use('/doctors', doctorRoutes);
app.use('/appointments', appointmentRoutes);
app.use('/payments', paymentRoutes);
app.use('/reports', reportRoutes);

app.use(notFound);
app.use(errorHandler);

export default app;
