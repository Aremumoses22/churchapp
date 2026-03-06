import cloudinary from '../config/cloudinary';
import { logger } from '../utils/logger';

type ResourceType = 'image' | 'video' | 'raw' | 'auto';

interface UploadOptions {
  folder: string;            // e.g., 'avatars', 'sermons/audio', 'photos'
  resourceType?: ResourceType;
  publicId?: string;
  transformation?: Record<string, unknown>[];
}

interface UploadResult {
  url: string;
  secureUrl: string;
  publicId: string;
  format: string;
  bytes: number;
  width?: number;
  height?: number;
  duration?: number;
}

/**
 * Cloudinary Upload Service
 */
export const uploadService = {
  /**
   * Upload a file buffer to Cloudinary
   */
  async uploadBuffer(
    buffer: Buffer,
    options: UploadOptions,
  ): Promise<UploadResult> {
    return new Promise((resolve, reject) => {
      const uploadStream = cloudinary.uploader.upload_stream(
        {
          folder: `churchapp/${options.folder}`,
          resource_type: options.resourceType || 'auto',
          public_id: options.publicId,
          transformation: options.transformation,
        },
        (error, result) => {
          if (error) {
            logger.error('Cloudinary upload error:', error);
            reject(error);
          } else if (result) {
            resolve({
              url: result.url,
              secureUrl: result.secure_url,
              publicId: result.public_id,
              format: result.format,
              bytes: result.bytes,
              width: result.width,
              height: result.height,
              duration: result.duration,
            });
          }
        },
      );

      uploadStream.end(buffer);
    });
  },

  /**
   * Upload a profile avatar (auto-resize to 400x400)
   */
  async uploadAvatar(buffer: Buffer, userId: string): Promise<UploadResult> {
    return this.uploadBuffer(buffer, {
      folder: 'avatars',
      resourceType: 'image',
      publicId: `avatar_${userId}`,
      transformation: [
        { width: 400, height: 400, crop: 'fill', gravity: 'face' },
        { quality: 'auto', fetch_format: 'auto' },
      ],
    });
  },

  /**
   * Upload a general image (event images, gallery photos, etc.)
   */
  async uploadImage(buffer: Buffer, folder: string, publicId?: string): Promise<UploadResult> {
    return this.uploadBuffer(buffer, {
      folder,
      resourceType: 'image',
      publicId,
      transformation: [
        { quality: 'auto', fetch_format: 'auto' },
      ],
    });
  },

  /**
   * Upload audio (sermons, podcasts)
   */
  async uploadAudio(buffer: Buffer, folder: string, publicId?: string): Promise<UploadResult> {
    return this.uploadBuffer(buffer, {
      folder,
      resourceType: 'video', // Cloudinary uses 'video' for audio too
      publicId,
    });
  },

  /**
   * Upload video (sermon videos)
   */
  async uploadVideo(buffer: Buffer, folder: string, publicId?: string): Promise<UploadResult> {
    return this.uploadBuffer(buffer, {
      folder,
      resourceType: 'video',
      publicId,
    });
  },

  /**
   * Delete a file from Cloudinary by public ID
   */
  async deleteFile(publicId: string, resourceType: ResourceType = 'image'): Promise<boolean> {
    try {
      await cloudinary.uploader.destroy(publicId, { resource_type: resourceType });
      logger.info(`Cloudinary file deleted: ${publicId}`);
      return true;
    } catch (error) {
      logger.error('Cloudinary delete error:', error);
      return false;
    }
  },

  /**
   * Generate a thumbnail URL from an existing Cloudinary image
   */
  getThumbnailUrl(publicId: string, width = 200, height = 200): string {
    return cloudinary.url(publicId, {
      width,
      height,
      crop: 'fill',
      quality: 'auto',
      fetch_format: 'auto',
    });
  },
};
