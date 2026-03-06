-- CreateEnum
CREATE TYPE "testament" AS ENUM ('OT', 'NT');

-- CreateEnum
CREATE TYPE "event_registration_status" AS ENUM ('REGISTERED', 'WAITLISTED', 'CANCELLED');

-- CreateTable
CREATE TABLE "sermon_series" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "image_url" VARCHAR(500),
    "start_date" DATE,
    "end_date" DATE,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "sermon_series_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "sermons" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "series_id" UUID,
    "title" VARCHAR(255) NOT NULL,
    "speaker" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "date" DATE NOT NULL,
    "duration" INTEGER,
    "audio_url" VARCHAR(500),
    "video_url" VARCHAR(500),
    "thumbnail_url" VARCHAR(500),
    "scripture_ref" VARCHAR(255),
    "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "like_count" INTEGER NOT NULL DEFAULT 0,
    "play_count" INTEGER NOT NULL DEFAULT 0,
    "is_featured" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "sermons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_sermon_progress" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "sermon_id" UUID NOT NULL,
    "position" INTEGER NOT NULL DEFAULT 0,
    "completed" BOOLEAN NOT NULL DEFAULT false,
    "last_played_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "user_sermon_progress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_sermon_notes" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "sermon_id" UUID NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "user_sermon_notes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "saved_sermons" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "sermon_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "saved_sermons_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "events" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "category" VARCHAR(100) NOT NULL,
    "image_url" VARCHAR(500),
    "location" VARCHAR(500),
    "start_date" TIMESTAMPTZ NOT NULL,
    "end_date" TIMESTAMPTZ,
    "is_recurring" BOOLEAN NOT NULL DEFAULT false,
    "recurrence_rule" VARCHAR(255),
    "registration_required" BOOLEAN NOT NULL DEFAULT false,
    "max_capacity" INTEGER,
    "registered_count" INTEGER NOT NULL DEFAULT 0,
    "is_featured" BOOLEAN NOT NULL DEFAULT false,
    "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "events_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_speakers" (
    "id" UUID NOT NULL,
    "event_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "title" VARCHAR(255),
    "image_url" VARCHAR(500),
    "sort_order" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "event_speakers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "event_registrations" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "event_id" UUID NOT NULL,
    "status" "event_registration_status" NOT NULL DEFAULT 'REGISTERED',
    "registered_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "event_registrations_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bible_books" (
    "id" UUID NOT NULL,
    "name" VARCHAR(100) NOT NULL,
    "abbreviation" VARCHAR(10) NOT NULL,
    "testament" "testament" NOT NULL,
    "book_order" INTEGER NOT NULL,
    "chapter_count" INTEGER NOT NULL,

    CONSTRAINT "bible_books_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bible_verses" (
    "id" UUID NOT NULL,
    "book_id" UUID NOT NULL,
    "chapter" INTEGER NOT NULL,
    "verse" INTEGER NOT NULL,
    "text" TEXT NOT NULL,

    CONSTRAINT "bible_verses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_verse_highlights" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "verse_id" UUID NOT NULL,
    "color" VARCHAR(20) NOT NULL DEFAULT 'yellow',
    "note" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "user_verse_highlights_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "devotionals" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "content" TEXT NOT NULL,
    "scripture_ref" VARCHAR(255) NOT NULL,
    "scripture_text" TEXT NOT NULL,
    "date" DATE NOT NULL,
    "image_url" VARCHAR(500),
    "author_name" VARCHAR(255) NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "devotionals_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_devotional_reads" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "devotional_id" UUID NOT NULL,
    "read_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "user_devotional_reads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reading_plans" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "image_url" VARCHAR(500),
    "duration_days" INTEGER NOT NULL,
    "category" VARCHAR(100) NOT NULL,
    "enrolled_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "reading_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reading_plan_days" (
    "id" UUID NOT NULL,
    "plan_id" UUID NOT NULL,
    "day_number" INTEGER NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "scripture_ref" VARCHAR(255) NOT NULL,
    "content" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reading_plan_days_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_reading_plans" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "plan_id" UUID NOT NULL,
    "started_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMPTZ,
    "current_day" INTEGER NOT NULL DEFAULT 1,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "user_reading_plans_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_reading_plan_progress" (
    "id" UUID NOT NULL,
    "user_reading_plan_id" UUID NOT NULL,
    "day_number" INTEGER NOT NULL,
    "completed_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reading_plan_day_id" UUID,

    CONSTRAINT "user_reading_plan_progress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "campuses" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "address" TEXT NOT NULL,
    "lat" DOUBLE PRECISION,
    "lng" DOUBLE PRECISION,
    "phone" VARCHAR(20),
    "email" VARCHAR(255),
    "image_url" VARCHAR(500),
    "is_primary" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "campuses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "service_times" (
    "id" UUID NOT NULL,
    "campus_id" UUID NOT NULL,
    "day_of_week" VARCHAR(20) NOT NULL,
    "time" VARCHAR(10) NOT NULL,
    "label" VARCHAR(100),

    CONSTRAINT "service_times_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "core_values" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT NOT NULL,
    "icon_url" VARCHAR(500),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "core_values_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "staff_members" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "bio" TEXT,
    "image_url" VARCHAR(500),
    "email" VARCHAR(255),
    "phone" VARCHAR(20),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "staff_members_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "faqs" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "question" TEXT NOT NULL,
    "answer" TEXT NOT NULL,
    "category" VARCHAR(100),
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "faqs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "sermon_series_church_id_idx" ON "sermon_series"("church_id");

-- CreateIndex
CREATE INDEX "sermons_church_id_idx" ON "sermons"("church_id");

-- CreateIndex
CREATE INDEX "sermons_series_id_idx" ON "sermons"("series_id");

-- CreateIndex
CREATE INDEX "sermons_date_idx" ON "sermons"("date");

-- CreateIndex
CREATE INDEX "sermons_is_featured_idx" ON "sermons"("is_featured");

-- CreateIndex
CREATE UNIQUE INDEX "user_sermon_progress_user_id_sermon_id_key" ON "user_sermon_progress"("user_id", "sermon_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_sermon_notes_user_id_sermon_id_key" ON "user_sermon_notes"("user_id", "sermon_id");

-- CreateIndex
CREATE UNIQUE INDEX "saved_sermons_user_id_sermon_id_key" ON "saved_sermons"("user_id", "sermon_id");

-- CreateIndex
CREATE INDEX "events_church_id_idx" ON "events"("church_id");

-- CreateIndex
CREATE INDEX "events_start_date_idx" ON "events"("start_date");

-- CreateIndex
CREATE INDEX "events_is_featured_idx" ON "events"("is_featured");

-- CreateIndex
CREATE INDEX "events_category_idx" ON "events"("category");

-- CreateIndex
CREATE UNIQUE INDEX "event_registrations_user_id_event_id_key" ON "event_registrations"("user_id", "event_id");

-- CreateIndex
CREATE UNIQUE INDEX "bible_books_book_order_key" ON "bible_books"("book_order");

-- CreateIndex
CREATE INDEX "bible_verses_book_id_chapter_idx" ON "bible_verses"("book_id", "chapter");

-- CreateIndex
CREATE UNIQUE INDEX "bible_verses_book_id_chapter_verse_key" ON "bible_verses"("book_id", "chapter", "verse");

-- CreateIndex
CREATE UNIQUE INDEX "user_verse_highlights_user_id_verse_id_key" ON "user_verse_highlights"("user_id", "verse_id");

-- CreateIndex
CREATE UNIQUE INDEX "devotionals_date_key" ON "devotionals"("date");

-- CreateIndex
CREATE INDEX "devotionals_church_id_idx" ON "devotionals"("church_id");

-- CreateIndex
CREATE INDEX "devotionals_date_idx" ON "devotionals"("date");

-- CreateIndex
CREATE UNIQUE INDEX "user_devotional_reads_user_id_devotional_id_key" ON "user_devotional_reads"("user_id", "devotional_id");

-- CreateIndex
CREATE INDEX "reading_plans_church_id_idx" ON "reading_plans"("church_id");

-- CreateIndex
CREATE UNIQUE INDEX "reading_plan_days_plan_id_day_number_key" ON "reading_plan_days"("plan_id", "day_number");

-- CreateIndex
CREATE UNIQUE INDEX "user_reading_plans_user_id_plan_id_key" ON "user_reading_plans"("user_id", "plan_id");

-- CreateIndex
CREATE UNIQUE INDEX "user_reading_plan_progress_user_reading_plan_id_day_number_key" ON "user_reading_plan_progress"("user_reading_plan_id", "day_number");

-- CreateIndex
CREATE INDEX "campuses_church_id_idx" ON "campuses"("church_id");

-- CreateIndex
CREATE INDEX "core_values_church_id_idx" ON "core_values"("church_id");

-- CreateIndex
CREATE INDEX "staff_members_church_id_idx" ON "staff_members"("church_id");

-- CreateIndex
CREATE INDEX "faqs_church_id_idx" ON "faqs"("church_id");

-- AddForeignKey
ALTER TABLE "sermon_series" ADD CONSTRAINT "sermon_series_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sermons" ADD CONSTRAINT "sermons_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "sermons" ADD CONSTRAINT "sermons_series_id_fkey" FOREIGN KEY ("series_id") REFERENCES "sermon_series"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_sermon_progress" ADD CONSTRAINT "user_sermon_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_sermon_progress" ADD CONSTRAINT "user_sermon_progress_sermon_id_fkey" FOREIGN KEY ("sermon_id") REFERENCES "sermons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_sermon_notes" ADD CONSTRAINT "user_sermon_notes_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_sermon_notes" ADD CONSTRAINT "user_sermon_notes_sermon_id_fkey" FOREIGN KEY ("sermon_id") REFERENCES "sermons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_sermons" ADD CONSTRAINT "saved_sermons_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_sermons" ADD CONSTRAINT "saved_sermons_sermon_id_fkey" FOREIGN KEY ("sermon_id") REFERENCES "sermons"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "events" ADD CONSTRAINT "events_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_speakers" ADD CONSTRAINT "event_speakers_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_registrations" ADD CONSTRAINT "event_registrations_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "event_registrations" ADD CONSTRAINT "event_registrations_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bible_verses" ADD CONSTRAINT "bible_verses_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "bible_books"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_verse_highlights" ADD CONSTRAINT "user_verse_highlights_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_verse_highlights" ADD CONSTRAINT "user_verse_highlights_verse_id_fkey" FOREIGN KEY ("verse_id") REFERENCES "bible_verses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "devotionals" ADD CONSTRAINT "devotionals_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_devotional_reads" ADD CONSTRAINT "user_devotional_reads_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_devotional_reads" ADD CONSTRAINT "user_devotional_reads_devotional_id_fkey" FOREIGN KEY ("devotional_id") REFERENCES "devotionals"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reading_plans" ADD CONSTRAINT "reading_plans_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reading_plan_days" ADD CONSTRAINT "reading_plan_days_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "reading_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_reading_plans" ADD CONSTRAINT "user_reading_plans_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_reading_plans" ADD CONSTRAINT "user_reading_plans_plan_id_fkey" FOREIGN KEY ("plan_id") REFERENCES "reading_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_reading_plan_progress" ADD CONSTRAINT "user_reading_plan_progress_user_reading_plan_id_fkey" FOREIGN KEY ("user_reading_plan_id") REFERENCES "user_reading_plans"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_reading_plan_progress" ADD CONSTRAINT "user_reading_plan_progress_reading_plan_day_id_fkey" FOREIGN KEY ("reading_plan_day_id") REFERENCES "reading_plan_days"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "campuses" ADD CONSTRAINT "campuses_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "service_times" ADD CONSTRAINT "service_times_campus_id_fkey" FOREIGN KEY ("campus_id") REFERENCES "campuses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "core_values" ADD CONSTRAINT "core_values_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "staff_members" ADD CONSTRAINT "staff_members_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "faqs" ADD CONSTRAINT "faqs_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;
