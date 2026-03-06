-- CreateEnum
CREATE TYPE "payment_method" AS ENUM ('CARD', 'BANK', 'MOBILE', 'WALLET');

-- CreateEnum
CREATE TYPE "payment_provider" AS ENUM ('PAYSTACK', 'STRIPE', 'MANUAL');

-- CreateEnum
CREATE TYPE "donation_status" AS ENUM ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "pledge_status" AS ENUM ('ACTIVE', 'COMPLETED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "giving_frequency" AS ENUM ('ONE_TIME', 'WEEKLY', 'BIWEEKLY', 'MONTHLY', 'QUARTERLY', 'ANNUALLY');

-- CreateEnum
CREATE TYPE "recurring_status" AS ENUM ('ACTIVE', 'PAUSED', 'CANCELLED');

-- CreateTable
CREATE TABLE "giving_categories" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "description" TEXT,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "giving_categories_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "giving_campaigns" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "image_url" VARCHAR(500),
    "goal_amount" DOUBLE PRECISION NOT NULL,
    "raised_amount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "donor_count" INTEGER NOT NULL DEFAULT 0,
    "start_date" DATE NOT NULL,
    "end_date" DATE,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "giving_campaigns_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "donations" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "category_id" UUID,
    "campaign_id" UUID,
    "amount" DOUBLE PRECISION NOT NULL,
    "currency" VARCHAR(10) NOT NULL DEFAULT 'NGN',
    "payment_method" "payment_method" NOT NULL,
    "payment_provider" "payment_provider" NOT NULL,
    "transaction_ref" VARCHAR(255) NOT NULL,
    "provider_ref" VARCHAR(255),
    "status" "donation_status" NOT NULL DEFAULT 'PENDING',
    "receipt_number" VARCHAR(50),
    "receipt_url" VARCHAR(500),
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "is_anonymous" BOOLEAN NOT NULL DEFAULT false,
    "note" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "donations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_payment_methods" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "type" "payment_method" NOT NULL,
    "provider" "payment_provider" NOT NULL,
    "last4" VARCHAR(4) NOT NULL,
    "brand" VARCHAR(20),
    "expiry_month" INTEGER,
    "expiry_year" INTEGER,
    "bank_name" VARCHAR(100),
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "provider_token" VARCHAR(500) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "user_payment_methods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pledges" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "campaign_id" UUID,
    "title" VARCHAR(255) NOT NULL,
    "total_amount" DOUBLE PRECISION NOT NULL,
    "paid_amount" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "frequency" "giving_frequency" NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE,
    "next_due_date" DATE,
    "status" "pledge_status" NOT NULL DEFAULT 'ACTIVE',
    "payments_completed" INTEGER NOT NULL DEFAULT 0,
    "total_payments" INTEGER,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "pledges_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "pledge_payments" (
    "id" UUID NOT NULL,
    "pledge_id" UUID NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "paid_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" "donation_status" NOT NULL DEFAULT 'SUCCESS',
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "pledge_payments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "recurring_donations" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "category_id" UUID NOT NULL,
    "payment_method_id" UUID NOT NULL,
    "amount" DOUBLE PRECISION NOT NULL,
    "currency" VARCHAR(10) NOT NULL DEFAULT 'NGN',
    "frequency" "giving_frequency" NOT NULL,
    "next_charge_date" DATE NOT NULL,
    "status" "recurring_status" NOT NULL DEFAULT 'ACTIVE',
    "failure_count" INTEGER NOT NULL DEFAULT 0,
    "last_charged_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "recurring_donations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "giving_categories_church_id_idx" ON "giving_categories"("church_id");

-- CreateIndex
CREATE INDEX "giving_campaigns_church_id_idx" ON "giving_campaigns"("church_id");

-- CreateIndex
CREATE INDEX "giving_campaigns_is_active_idx" ON "giving_campaigns"("is_active");

-- CreateIndex
CREATE UNIQUE INDEX "donations_transaction_ref_key" ON "donations"("transaction_ref");

-- CreateIndex
CREATE UNIQUE INDEX "donations_receipt_number_key" ON "donations"("receipt_number");

-- CreateIndex
CREATE INDEX "donations_user_id_idx" ON "donations"("user_id");

-- CreateIndex
CREATE INDEX "donations_church_id_idx" ON "donations"("church_id");

-- CreateIndex
CREATE INDEX "donations_status_idx" ON "donations"("status");

-- CreateIndex
CREATE INDEX "donations_created_at_idx" ON "donations"("created_at");

-- CreateIndex
CREATE INDEX "user_payment_methods_user_id_idx" ON "user_payment_methods"("user_id");

-- CreateIndex
CREATE INDEX "pledges_user_id_idx" ON "pledges"("user_id");

-- CreateIndex
CREATE INDEX "pledges_church_id_idx" ON "pledges"("church_id");

-- CreateIndex
CREATE INDEX "pledges_status_idx" ON "pledges"("status");

-- CreateIndex
CREATE INDEX "pledge_payments_pledge_id_idx" ON "pledge_payments"("pledge_id");

-- CreateIndex
CREATE INDEX "recurring_donations_user_id_idx" ON "recurring_donations"("user_id");

-- CreateIndex
CREATE INDEX "recurring_donations_church_id_idx" ON "recurring_donations"("church_id");

-- CreateIndex
CREATE INDEX "recurring_donations_status_next_charge_date_idx" ON "recurring_donations"("status", "next_charge_date");

-- AddForeignKey
ALTER TABLE "giving_categories" ADD CONSTRAINT "giving_categories_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "giving_campaigns" ADD CONSTRAINT "giving_campaigns_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "donations" ADD CONSTRAINT "donations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "donations" ADD CONSTRAINT "donations_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "donations" ADD CONSTRAINT "donations_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "giving_categories"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "donations" ADD CONSTRAINT "donations_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "giving_campaigns"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_payment_methods" ADD CONSTRAINT "user_payment_methods_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pledges" ADD CONSTRAINT "pledges_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pledges" ADD CONSTRAINT "pledges_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pledges" ADD CONSTRAINT "pledges_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "giving_campaigns"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "pledge_payments" ADD CONSTRAINT "pledge_payments_pledge_id_fkey" FOREIGN KEY ("pledge_id") REFERENCES "pledges"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recurring_donations" ADD CONSTRAINT "recurring_donations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recurring_donations" ADD CONSTRAINT "recurring_donations_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recurring_donations" ADD CONSTRAINT "recurring_donations_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "giving_categories"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "recurring_donations" ADD CONSTRAINT "recurring_donations_payment_method_id_fkey" FOREIGN KEY ("payment_method_id") REFERENCES "user_payment_methods"("id") ON DELETE CASCADE ON UPDATE CASCADE;
