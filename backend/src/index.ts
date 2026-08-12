// import express, { Express, Request, Response, NextFunction } from 'express';
// import helmet from 'helmet';
// import dotenv from 'dotenv';
// import path from 'path';
// import multer from 'multer';
// import { initializeEncryption } from './utils/encryption';
// import { initializeScheduledJobs } from './services/scheduledJobsService';
// import { retryFailedBackups } from './services/emailService';
// import authRoutes from './routes/authRoutes';
// import patientRoutes from './routes/patientRoutes';
// import panicWipeRoutes from './routes/panicWipeRoutes';
// import auditRoutes from './routes/auditRoutes';
// import userRoutes from './routes/userRoutes';
// import { PrismaClient } from '@prisma/client';

// const environment = process.env.NODE_ENV || 'development';

// dotenv.config({
//   path: path.resolve(process.cwd(), `.env.${environment}`)
// });

// console.log(`📡 Loaded configuration from: .env.${environment}`);

// const app: Express = express();
// const prisma = new PrismaClient();
// const PORT = process.env.PORT || 3000;
// const upload = multer(); // Initialize multer for file uploads

// // Middleware
// app.use(helmet());
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

// // CORS middleware
// app.use((req: Request, res: Response, next: NextFunction) => {
//   res.header('Access-Control-Allow-Origin', '*');
//   res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, x-admin-secret');
//   res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  
//   if (req.method === 'OPTIONS') {
//     res.sendStatus(200);
//   } else {
//     next();
//   }
// });

// // Initialize encryption service
// try {
//   const encryptionKey = process.env.ENCRYPTION_KEY;
//   if (!encryptionKey) {
//     throw new Error('ENCRYPTION_KEY environment variable is not set');
//   }
//   initializeEncryption(encryptionKey);
//   console.log('✓ Encryption service initialized');
// } catch (error) {
//   console.error('Failed to initialize encryption:', error);
//   process.exit(1);
// }

// // Routes
// app.use('/api/auth', authRoutes);
// app.use('/api/patients', patientRoutes);
// app.use('/api/users', userRoutes);
// app.use('/api/panic-wipe', panicWipeRoutes);
// app.use('/api/audit', auditRoutes);

// // Initialize scheduled jobs
// initializeScheduledJobs();

// // Health check
// app.get('/health', (req: Request, res: Response) => {
//   res.json({
//     status: 'ok',
//     timestamp: new Date().toISOString()
//   });
// });

// // Admin retry endpoint for failed backup emails
// app.get('/api/admin/retry-backup', async (req: Request, res: Response) => {
//   const secret = String(req.query.secret || '');
//   if (!process.env.ADMIN_SECRET || secret !== process.env.ADMIN_SECRET) {
//     return res.status(404).json({ error: 'Route not found' });
//   }

//   try {
//     const retryResult = await retryFailedBackups();
//     return res.json({
//       success: true,
//       message: 'Retry completed',
//       ...retryResult
//     });
//   } catch (error) {
//     console.error('Admin retry-backup failed:', error);
//     return res.status(500).json({ error: 'Retry failed', message: (error as Error).message });
//   }
// });

// // ============================================================
// // ⭐ FINAL BACKUP EMAIL ROUTE (ERROR FREE) ⭐
// // ============================================================

// app.post('/api/backup/send-email', upload.single('file'), async (req: Request, res: Response) => {
//   try {
//     // Authorization check
//     const authHeader = req.headers['authorization'];
//     if (!authHeader || !authHeader.startsWith('Bearer ')) {
//       return res.status(401).json({ success: false, message: 'Unauthorized' });
//     }

//     const { recipientEmail, customMessage } = req.body;
//     const file = req.file; 

//     if (!file) {
//       return res.status(400).json({ success: false, message: 'No file uploaded' });
//     }

//     // Import email service & encryption
//     const emailService = await import('./services/emailService');
//     const { getEncryption } = await import('./utils/encryption');

//     // 1. Convert file buffer to string (CSV data)
//     const csvString = file.buffer.toString('utf-8');

//     // 2. Encrypt the CSV data
//     const encryption = getEncryption();
//     const encryptedBackup = encryption.encrypt(csvString);

//     // 3. Prepare file name
//     const fileName = file.originalname.replace('.csv', '.enc');

//     // 4. Send the email using emailService's function
//     const emailSent = await emailService.sendBackupEmailTo(
//       recipientEmail,
//       Buffer.from(encryptedBackup, 'utf-8'),
//       fileName,
//       customMessage || '📁 Patient Data Backup'
//     );

//     if (emailSent) {
//       res.status(200).json({ success: true, message: 'Email sent successfully' });
//     } else {
//       res.status(500).json({ success: false, message: 'Failed to send email' });
//     }

//   } catch (error: any) {
//     console.error('❌ Send Email Error:', error);
//     res.status(500).json({ success: false, message: error.message });
//   }
// });

// // ============================================================
// // ⭐ TEST BACKUP ROUTE ⭐
// // ============================================================

// app.post('/api/backup/test', async (req: Request, res: Response) => {
//   try {
//     const adminSecret = req.headers['x-admin-secret'];
//     if (adminSecret !== process.env.ADMIN_SECRET) {
//       return res.status(403).json({ error: 'Unauthorized' });
//     }

//     const emailService = await import('./services/emailService');
    
//     console.log('🧪 Test backup triggered...');
//     const result = await emailService.sendWeeklyBackupEmail();
    
//     if (result) {
//       res.json({ 
//         success: true, 
//         message: '✅ Test backup email sent successfully! Check your email.' 
//       });
//     } else {
//       res.status(500).json({ 
//         error: '❌ Test backup failed. Check server logs.' 
//       });
//     }
//   } catch (error: any) {
//     console.error('Test backup error:', error);
//     res.status(500).json({ error: error.message });
//   }
// });

// console.log('📧 Backup routes initialized');

// // 404 handler
// app.use((req: Request, res: Response) => {
//   res.status(404).json({ error: 'Route not found' });
// });

// // Error handler
// app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
//   console.error('Unhandled error:', err);
//   res.status(500).json({
//     error: 'Internal server error',
//     message: process.env.NODE_ENV === 'development' ? err.message : undefined
//   });
// });

// // Start server
// const server = app.listen(PORT, () => {
//   console.log(`\n🚀 IVF Backend Server`);
//   console.log(`📍 Running on http://localhost:${PORT}`);
//   console.log(`🔐 Environment: ${process.env.NODE_ENV || 'development'}`);
//   console.log(`\n✓ Server is ready for requests\n`);

//   void retryFailedBackupsOnStartup();
// });

// async function retryFailedBackupsOnStartup() {
//   try {
//     const retryResult = await retryFailedBackups();
//     if (retryResult.total > 0) {
//       console.log(`🛠️ Retried ${retryResult.total} failed backup email(s): ${retryResult.succeeded} succeeded, ${retryResult.failed} failed.`);
//     }
//   } catch (error) {
//     console.error('Failed to retry pending backup emails on startup:', error);
//   }
// }

// // Graceful shutdown
// process.on('SIGINT', async () => {
//   console.log('\n\n🛑 Shutting down gracefully...');
//   server.close(async () => {
//     await prisma.$disconnect();
//     console.log('✓ Database connection closed');
//     process.exit(0);
//   });
// });

// process.on('SIGTERM', async () => {
//   console.log('\n\n🛑 Shutting down gracefully...');
//   server.close(async () => {
//     await prisma.$disconnect();
//     console.log('✓ Database connection closed');
//     process.exit(0);
//   });
// });

// export default app;


import express, { Express, Request, Response, NextFunction } from 'express';
import helmet from 'helmet';
import dotenv from 'dotenv';
import path from 'path';
import multer from 'multer';
import cors from 'cors';
import { initializeEncryption } from './utils/encryption';
import { initializeScheduledJobs } from './services/scheduledJobsService';
import { retryFailedBackups } from './services/emailService';
import authRoutes from './routes/authRoutes';
import patientRoutes from './routes/patientRoutes';
import panicWipeRoutes from './routes/panicWipeRoutes';
import auditRoutes from './routes/auditRoutes';
import userRoutes from './routes/userRoutes';
import { PrismaClient } from '@prisma/client';

const environment = process.env.NODE_ENV || 'development';

dotenv.config({
  path: path.resolve(process.cwd(), `.env.${environment}`)
});

console.log(`📡 Loaded configuration from: .env.${environment}`);

const app: Express = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 3000;
const upload = multer(); // Initialize multer for file uploads

// ============================================================
// ✅ MIDDLEWARE ✅
// ============================================================

// Helmet for security
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));

// Body parsers
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

// ============================================================
// ✅ CORS MIDDLEWARE - COMPLETE FIX ✅
// ============================================================
app.use((req: Request, res: Response, next: NextFunction) => {
  // Allow specific origins
  const allowedOrigins = [
    'https://patient-manager-three.vercel.app',
    'https://patient-manager.vercel.app',
    'https://patient-manager-70wtwyqbi-hrms-7192s-projects.vercel.app',
    'https://patient-manager-kip5488mz-hrms-7192s-projects.vercel.app',
    'http://localhost:3000',
    'http://localhost:3001',
    'http://localhost:5000',
    'http://localhost:8080'
  ];
  
  const origin = req.headers.origin || '';
  
  // Check if origin is allowed, or allow all in development
  if (allowedOrigins.includes(origin) || process.env.NODE_ENV === 'development') {
    res.header('Access-Control-Allow-Origin', origin);
  } else {
    // Allow all origins as fallback (for testing)
    res.header('Access-Control-Allow-Origin', '*');
  }
  
  // Set CORS headers
  res.header('Access-Control-Allow-Credentials', 'true');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization, x-admin-secret');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, PATCH, DELETE, OPTIONS');
  res.header('Access-Control-Expose-Headers', 'Content-Length, X-Requested-With');
  
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
});

// ============================================================
// ✅ ENCRYPTION INITIALIZATION ✅
// ============================================================

try {
  const encryptionKey = process.env.ENCRYPTION_KEY;
  if (!encryptionKey) {
    throw new Error('ENCRYPTION_KEY environment variable is not set');
  }
  initializeEncryption(encryptionKey);
  console.log('✓ Encryption service initialized');
} catch (error) {
  console.error('Failed to initialize encryption:', error);
  process.exit(1);
}

// ============================================================
// ✅ ROUTES ✅
// ============================================================

app.use('/api/auth', authRoutes);
app.use('/api/patients', patientRoutes);
app.use('/api/users', userRoutes);
app.use('/api/panic-wipe', panicWipeRoutes);
app.use('/api/audit', auditRoutes);

// Initialize scheduled jobs
initializeScheduledJobs();

// ============================================================
// ✅ HEALTH CHECK ✅
// ============================================================

app.get('/health', (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString()
  });
});

// ============================================================
// ✅ ADMIN RETRY BACKUP ENDPOINT ✅
// ============================================================

app.get('/api/admin/retry-backup', async (req: Request, res: Response) => {
  const secret = String(req.query.secret || '');
  if (!process.env.ADMIN_SECRET || secret !== process.env.ADMIN_SECRET) {
    return res.status(404).json({ error: 'Route not found' });
  }

  try {
    const retryResult = await retryFailedBackups();
    return res.json({
      success: true,
      message: 'Retry completed',
      ...retryResult
    });
  } catch (error) {
    console.error('Admin retry-backup failed:', error);
    return res.status(500).json({ error: 'Retry failed', message: (error as Error).message });
  }
});

// ============================================================
// ⭐ BACKUP EMAIL ROUTE ⭐
// ============================================================

app.post('/api/backup/send-email', upload.single('file'), async (req: Request, res: Response) => {
  try {
    // Authorization check
    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ success: false, message: 'Unauthorized' });
    }

    const { recipientEmail, customMessage } = req.body;
    const file = req.file; 

    if (!file) {
      return res.status(400).json({ success: false, message: 'No file uploaded' });
    }

    // Import email service & encryption
    const emailService = await import('./services/emailService');
    const { getEncryption } = await import('./utils/encryption');

    // 1. Convert file buffer to string (CSV data)
    const csvString = file.buffer.toString('utf-8');

    // 2. Encrypt the CSV data
    const encryption = getEncryption();
    const encryptedBackup = encryption.encrypt(csvString);

    // 3. Prepare file name
    const fileName = file.originalname.replace('.csv', '.enc');

    // 4. Send the email using emailService's function
    const emailSent = await emailService.sendBackupEmailTo(
      recipientEmail,
      Buffer.from(encryptedBackup, 'utf-8'),
      fileName,
      customMessage || '📁 Patient Data Backup'
    );

    if (emailSent) {
      res.status(200).json({ success: true, message: 'Email sent successfully' });
    } else {
      res.status(500).json({ success: false, message: 'Failed to send email' });
    }

  } catch (error: any) {
    console.error('❌ Send Email Error:', error);
    res.status(500).json({ success: false, message: error.message });
  }
});

// ============================================================
// ⭐ TEST BACKUP ROUTE ⭐
// ============================================================

app.post('/api/backup/test', async (req: Request, res: Response) => {
  try {
    const adminSecret = req.headers['x-admin-secret'];
    if (adminSecret !== process.env.ADMIN_SECRET) {
      return res.status(403).json({ error: 'Unauthorized' });
    }

    const emailService = await import('./services/emailService');
    
    console.log('🧪 Test backup triggered...');
    const result = await emailService.sendWeeklyBackupEmail();
    
    if (result) {
      res.json({ 
        success: true, 
        message: '✅ Test backup email sent successfully! Check your email.' 
      });
    } else {
      res.status(500).json({ 
        error: '❌ Test backup failed. Check server logs.' 
      });
    }
  } catch (error: any) {
    console.error('Test backup error:', error);
    res.status(500).json({ error: error.message });
  }
});

console.log('📧 Backup routes initialized');

// ============================================================
// ✅ 404 HANDLER ✅
// ============================================================

app.use((req: Request, res: Response) => {
  res.status(404).json({ error: 'Route not found' });
});

// ============================================================
// ✅ ERROR HANDLER ✅
// ============================================================

app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// ============================================================
// ✅ START SERVER ✅
// ============================================================

const server = app.listen(PORT, () => {
  console.log(`\n🚀 IVF Backend Server`);
  console.log(`📍 Running on http://localhost:${PORT}`);
  console.log(`🔐 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`\n✓ Server is ready for requests\n`);

  void retryFailedBackupsOnStartup();
});

async function retryFailedBackupsOnStartup() {
  try {
    const retryResult = await retryFailedBackups();
    if (retryResult.total > 0) {
      console.log(`🛠️ Retried ${retryResult.total} failed backup email(s): ${retryResult.succeeded} succeeded, ${retryResult.failed} failed.`);
    }
  } catch (error) {
    console.error('Failed to retry pending backup emails on startup:', error);
  }
}

// ============================================================
// ✅ GRACEFUL SHUTDOWN ✅
// ============================================================

process.on('SIGINT', async () => {
  console.log('\n\n🛑 Shutting down gracefully...');
  server.close(async () => {
    await prisma.$disconnect();
    console.log('✓ Database connection closed');
    process.exit(0);
  });
});

process.on('SIGTERM', async () => {
  console.log('\n\n🛑 Shutting down gracefully...');
  server.close(async () => {
    await prisma.$disconnect();
    console.log('✓ Database connection closed');
    process.exit(0);
  });
});

export default app;