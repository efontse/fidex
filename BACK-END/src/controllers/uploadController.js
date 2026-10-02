const fs = require('fs');
const path = require('path');

const uploadDir = path.resolve(__dirname, '../../public/uploads');

// Ensure directory exists
if (!fs.existsSync(uploadDir)) {
  fs.mkdirSync(uploadDir, { recursive: true });
}

class UploadController {
  /**
   * Upload image (accepts base64 or data URI)
   * POST /api/upload
   */
  static async uploadImage(req, res, next) {
    try {
      const { image, filename } = req.body;

      if (!image) {
        return res.status(400).json({
          success: false,
          error: {
            message: 'No image data provided. Provide base64 image or data URI.',
            code: 'MISSING_IMAGE'
          }
        });
      }

      // Parse data URI if present
      let base64Data = image;
      let extension = 'jpg';

      if (image.startsWith('data:')) {
        const matches = image.match(/^data:image\/([a-zA-Z0-9+]+);base64,(.+)$/);
        if (matches && matches.length === 3) {
          extension = matches[1] === 'jpeg' ? 'jpg' : matches[1];
          base64Data = matches[2];
        } else {
          base64Data = image.replace(/^data:image\/[a-zA-Z0-9+]+;base64,/, '');
        }
      }

      const safeName = `product_${Date.now()}_${Math.random().toString(36).substring(2, 8)}.${extension}`;
      const filePath = path.join(uploadDir, safeName);

      const buffer = Buffer.from(base64Data, 'base64');
      fs.writeFileSync(filePath, buffer);

      const relativeUrl = `/public/uploads/${safeName}`;
      const protocol = req.protocol || 'http';
      const host = req.get('host') || 'localhost:5000';
      const fullUrl = `${protocol}://${host}${relativeUrl}`;

      return res.status(201).json({
        success: true,
        message: 'Product image uploaded successfully.',
        data: {
          url: relativeUrl,
          fullUrl,
          filename: safeName
        }
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = UploadController;
