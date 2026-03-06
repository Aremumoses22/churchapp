import PDFDocument from 'pdfkit';
import { logger } from '../utils/logger';

// ────────────────────────────────────────────────────
// Receipt Service
// Generates PDF giving receipts and optionally uploads
// to Cloudinary + emails to the donor
// ────────────────────────────────────────────────────

interface ReceiptData {
  receiptNumber: string;
  donorName: string;
  donorEmail: string;
  churchName: string;
  churchAddress?: string;
  churchEin?: string; // Tax ID for tax-deductible receipts
  amount: number;
  currency: string;
  category?: string;
  campaign?: string;
  paymentMethod: string;
  transactionRef: string;
  date: Date;
  note?: string;
}

/**
 * Generate a PDF receipt and return as a Buffer
 */
async function generateReceiptPdf(data: ReceiptData): Promise<Buffer> {
  return new Promise((resolve, reject) => {
    try {
      const doc = new PDFDocument({
        size: 'A4',
        margin: 50,
        info: {
          Title: `Donation Receipt - ${data.receiptNumber}`,
          Author: data.churchName,
          Subject: 'Donation Receipt',
        },
      });

      const chunks: Uint8Array[] = [];
      doc.on('data', (chunk: Uint8Array) => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      // ── Header ─────────────────────────────────────
      doc
        .fontSize(24)
        .font('Helvetica-Bold')
        .text(data.churchName, { align: 'center' });

      if (data.churchAddress) {
        doc
          .fontSize(10)
          .font('Helvetica')
          .text(data.churchAddress, { align: 'center' });
      }

      doc.moveDown(0.5);

      // Divider line
      doc
        .moveTo(50, doc.y)
        .lineTo(545, doc.y)
        .strokeColor('#6C63FF')
        .lineWidth(2)
        .stroke();

      doc.moveDown(1);

      // ── Title ──────────────────────────────────────
      doc
        .fontSize(18)
        .font('Helvetica-Bold')
        .fillColor('#333333')
        .text('DONATION RECEIPT', { align: 'center' });

      doc.moveDown(0.5);

      doc
        .fontSize(12)
        .font('Helvetica')
        .fillColor('#666666')
        .text(`Receipt #${data.receiptNumber}`, { align: 'center' });

      doc.moveDown(1.5);

      // ── Amount ─────────────────────────────────────
      const formattedAmount = formatCurrency(data.amount, data.currency);
      doc
        .fontSize(32)
        .font('Helvetica-Bold')
        .fillColor('#6C63FF')
        .text(formattedAmount, { align: 'center' });

      doc.moveDown(1.5);

      // ── Details Table ──────────────────────────────
      const leftCol = 70;
      const rightCol = 250;
      let y = doc.y;

      const details: [string, string][] = [
        ['Donor', data.donorName],
        ['Email', data.donorEmail],
        ['Date', data.date.toLocaleDateString('en-US', {
          year: 'numeric', month: 'long', day: 'numeric',
        })],
        ['Time', data.date.toLocaleTimeString('en-US', {
          hour: '2-digit', minute: '2-digit',
        })],
        ['Amount', formattedAmount],
        ['Payment Method', data.paymentMethod],
        ['Transaction Ref', data.transactionRef],
      ];

      if (data.category) {
        details.push(['Category', data.category]);
      }
      if (data.campaign) {
        details.push(['Campaign', data.campaign]);
      }
      if (data.note) {
        details.push(['Note', data.note]);
      }

      for (const [label, value] of details) {
        // Alternating background
        if (details.indexOf([label, value]) % 2 === 0) {
          doc.rect(50, y - 2, 495, 22).fill('#F8F9FA');
        }

        doc
          .fontSize(11)
          .font('Helvetica-Bold')
          .fillColor('#333333')
          .text(label, leftCol, y);

        doc
          .fontSize(11)
          .font('Helvetica')
          .fillColor('#555555')
          .text(value, rightCol, y, { width: 280 });

        y += 24;
      }

      doc.y = y + 20;

      // ── Tax Info ───────────────────────────────────
      if (data.churchEin) {
        doc
          .moveTo(50, doc.y)
          .lineTo(545, doc.y)
          .strokeColor('#E0E0E0')
          .lineWidth(0.5)
          .stroke();

        doc.moveDown(0.5);

        doc
          .fontSize(9)
          .font('Helvetica')
          .fillColor('#999999')
          .text(
            `${data.churchName} is a tax-exempt organization under Section 501(c)(3) of the Internal Revenue Code.`,
            { align: 'center' },
          );

        doc
          .fontSize(9)
          .text(`EIN: ${data.churchEin}`, { align: 'center' });

        doc.moveDown(0.5);

        doc
          .fontSize(9)
          .text(
            'No goods or services were provided in exchange for this contribution. ' +
            'This receipt may be used for tax deduction purposes.',
            { align: 'center' },
          );
      }

      // ── Footer ─────────────────────────────────────
      doc.moveDown(2);

      doc
        .moveTo(50, doc.y)
        .lineTo(545, doc.y)
        .strokeColor('#E0E0E0')
        .lineWidth(0.5)
        .stroke();

      doc.moveDown(0.5);

      doc
        .fontSize(9)
        .font('Helvetica')
        .fillColor('#999999')
        .text('Thank you for your generous contribution! 🙏', { align: 'center' });

      doc
        .fontSize(8)
        .text(`Generated on ${new Date().toISOString()}`, { align: 'center' });

      doc.end();
    } catch (error) {
      reject(error);
    }
  });
}

/**
 * Generate receipt, upload to Cloudinary, and optionally email to donor
 */
async function generateAndUploadReceipt(data: ReceiptData): Promise<string | null> {
  try {
    const pdfBuffer = await generateReceiptPdf(data);

    // In dev mode, just log and return a fake URL
    logger.info(`📄 Receipt generated: ${data.receiptNumber} (${pdfBuffer.length} bytes)`);

    // Try to upload to Cloudinary
    try {
      const { uploadService } = await import('./upload.service');
      const result = await uploadService.uploadBuffer(pdfBuffer, {
        folder: 'receipts',
        resourceType: 'raw',
        publicId: data.receiptNumber,
      });
      if (result) {
        return result.secureUrl || result.url;
      }
    } catch {
      logger.warn('Cloudinary upload not available — receipt generated but not uploaded');
    }

    // Return null if upload failed (receipt can still be generated on-demand)
    return null;
  } catch (error) {
    logger.error('Receipt generation failed:', error);
    return null;
  }
}

/**
 * Format currency for display
 */
function formatCurrency(amount: number, currency: string): string {
  const symbols: Record<string, string> = {
    NGN: '₦',
    USD: '$',
    GBP: '£',
    EUR: '€',
    GHS: '₵',
    KES: 'KSh',
    ZAR: 'R',
  };

  const symbol = symbols[currency.toUpperCase()] || currency;
  return `${symbol}${amount.toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  })}`;
}

export const receiptService = {
  generateReceiptPdf,
  generateAndUploadReceipt,
  formatCurrency,
};
