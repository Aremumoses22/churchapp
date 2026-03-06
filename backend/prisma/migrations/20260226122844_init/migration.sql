-- CreateEnum
CREATE TYPE "user_role" AS ENUM ('MEMBER', 'LEADER', 'PASTOR', 'ADMIN', 'SUPER_ADMIN');

-- CreateTable
CREATE TABLE "churches" (
    "id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "tagline" VARCHAR(500),
    "code" VARCHAR(10) NOT NULL,
    "mission" TEXT,
    "vision" TEXT,
    "ein" VARCHAR(20),
    "phone" VARCHAR(20),
    "email" VARCHAR(255),
    "website" VARCHAR(500),
    "address" TEXT,
    "logo_url" VARCHAR(500),
    "cover_image_url" VARCHAR(500),
    "social_links" JSONB NOT NULL DEFAULT '{}',
    "settings" JSONB NOT NULL DEFAULT '{}',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "churches_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "users" (
    "id" UUID NOT NULL,
    "church_id" UUID,
    "email" VARCHAR(255) NOT NULL,
    "password_hash" VARCHAR(255) NOT NULL,
    "email_verified" BOOLEAN NOT NULL DEFAULT false,
    "verification_token" VARCHAR(255),
    "verification_expires" TIMESTAMPTZ,
    "reset_token" VARCHAR(255),
    "reset_token_expires" TIMESTAMPTZ,
    "refresh_token" VARCHAR(500),
    "name" VARCHAR(255) NOT NULL,
    "phone" VARCHAR(20),
    "bio" TEXT,
    "avatar_url" VARCHAR(500),
    "department" VARCHAR(100),
    "role" "user_role" NOT NULL DEFAULT 'MEMBER',
    "joined_date" DATE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "is_directory_visible" BOOLEAN NOT NULL DEFAULT true,
    "has_completed_setup" BOOLEAN NOT NULL DEFAULT false,
    "fcm_tokens" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "notification_prefs" JSONB NOT NULL DEFAULT '{}',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "churches_code_key" ON "churches"("code");

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_church_id_idx" ON "users"("church_id");

-- CreateIndex
CREATE INDEX "users_email_idx" ON "users"("email");

-- CreateIndex
CREATE INDEX "users_verification_token_idx" ON "users"("verification_token");

-- CreateIndex
CREATE INDEX "users_reset_token_idx" ON "users"("reset_token");

-- AddForeignKey
ALTER TABLE "users" ADD CONSTRAINT "users_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE SET NULL ON UPDATE CASCADE;
