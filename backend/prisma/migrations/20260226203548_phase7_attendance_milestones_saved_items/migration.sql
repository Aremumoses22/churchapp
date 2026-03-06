-- CreateEnum
CREATE TYPE "volunteer_signup_status" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');

-- CreateEnum
CREATE TYPE "shift_status" AS ENUM ('SCHEDULED', 'CHECKED_IN', 'COMPLETED', 'SWAPPED');

-- CreateEnum
CREATE TYPE "checkin_status" AS ENUM ('CHECKED_IN', 'CHECKED_OUT');

-- CreateEnum
CREATE TYPE "song_section_type" AS ENUM ('VERSE', 'CHORUS', 'BRIDGE', 'PRE_CHORUS', 'OUTRO', 'INTRO');

-- CreateEnum
CREATE TYPE "service_type" AS ENUM ('SUNDAY', 'MIDWEEK', 'SPECIAL', 'YOUTH', 'PRAYER');

-- CreateEnum
CREATE TYPE "checkin_method" AS ENUM ('MANUAL', 'QR', 'GEOFENCE');

-- CreateEnum
CREATE TYPE "milestone_type" AS ENUM ('SALVATION', 'BAPTISM', 'FIRST_SERVE', 'SMALL_GROUP', 'MINISTRY_LEADER', 'FIRST_GIVE', 'ONE_YEAR', 'INVITE_FRIEND');

-- CreateEnum
CREATE TYPE "saved_entity_type" AS ENUM ('SERMON', 'EVENT', 'DEVOTIONAL', 'VERSE', 'THREAD', 'SONG');

-- AlterEnum
ALTER TYPE "notification_type" ADD VALUE 'KIDS';

-- CreateTable
CREATE TABLE "volunteer_opportunities" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "department" VARCHAR(100) NOT NULL,
    "requirements" TEXT,
    "image_url" VARCHAR(500),
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "volunteer_opportunities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "volunteer_signups" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "opportunity_id" UUID NOT NULL,
    "status" "volunteer_signup_status" NOT NULL DEFAULT 'PENDING',
    "applied_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "volunteer_signups_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "roster_shifts" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "opportunity_id" UUID NOT NULL,
    "date" DATE NOT NULL,
    "start_time" VARCHAR(10) NOT NULL,
    "end_time" VARCHAR(10) NOT NULL,
    "status" "shift_status" NOT NULL DEFAULT 'SCHEDULED',
    "checkin_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "roster_shifts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "children" (
    "id" UUID NOT NULL,
    "parent_id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "first_name" VARCHAR(100) NOT NULL,
    "last_name" VARCHAR(100) NOT NULL,
    "date_of_birth" DATE NOT NULL,
    "allergies" TEXT,
    "medical_notes" TEXT,
    "photo_url" VARCHAR(500),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "children_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rooms" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "name" VARCHAR(255) NOT NULL,
    "age_group" VARCHAR(100) NOT NULL,
    "capacity" INTEGER NOT NULL,
    "current_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "rooms_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "check_ins" (
    "id" UUID NOT NULL,
    "child_id" UUID NOT NULL,
    "room_id" UUID NOT NULL,
    "parent_id" UUID NOT NULL,
    "checked_in_by" UUID NOT NULL,
    "security_code" VARCHAR(10) NOT NULL,
    "status" "checkin_status" NOT NULL DEFAULT 'CHECKED_IN',
    "checked_in_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "checked_out_at" TIMESTAMPTZ,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "check_ins_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "photo_albums" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "cover_image_url" VARCHAR(500),
    "photo_count" INTEGER NOT NULL DEFAULT 0,
    "event_id" UUID,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "photo_albums_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "photos" (
    "id" UUID NOT NULL,
    "album_id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "uploaded_by_id" UUID NOT NULL,
    "image_url" VARCHAR(500) NOT NULL,
    "thumbnail_url" VARCHAR(500),
    "caption" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "photos_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "podcast_episodes" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "audio_url" VARCHAR(500) NOT NULL,
    "duration" INTEGER NOT NULL,
    "thumbnail_url" VARCHAR(500),
    "published_at" TIMESTAMPTZ NOT NULL,
    "play_count" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "podcast_episodes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "user_podcast_progress" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "episode_id" UUID NOT NULL,
    "position" INTEGER NOT NULL DEFAULT 0,
    "completed" BOOLEAN NOT NULL DEFAULT false,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "user_podcast_progress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "worship_songs" (
    "id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "artist" VARCHAR(255) NOT NULL,
    "key" VARCHAR(10),
    "tempo" INTEGER,
    "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "worship_songs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "song_sections" (
    "id" UUID NOT NULL,
    "song_id" UUID NOT NULL,
    "type" "song_section_type" NOT NULL,
    "sort_order" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "song_sections_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lyric_lines" (
    "id" UUID NOT NULL,
    "section_id" UUID NOT NULL,
    "line_number" INTEGER NOT NULL,
    "lyrics" TEXT NOT NULL,
    "chords" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "lyric_lines_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "attendances" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "service_date" DATE NOT NULL,
    "service_type" "service_type" NOT NULL DEFAULT 'SUNDAY',
    "checkin_method" "checkin_method" NOT NULL DEFAULT 'MANUAL',
    "notes" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "attendances_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "spiritual_milestones" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "church_id" UUID NOT NULL,
    "type" "milestone_type" NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "description" TEXT,
    "achieved_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "icon_url" VARCHAR(500),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "spiritual_milestones_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "saved_items" (
    "id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "entity_type" "saved_entity_type" NOT NULL,
    "entity_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL,

    CONSTRAINT "saved_items_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "volunteer_opportunities_church_id_idx" ON "volunteer_opportunities"("church_id");

-- CreateIndex
CREATE INDEX "volunteer_opportunities_department_idx" ON "volunteer_opportunities"("department");

-- CreateIndex
CREATE INDEX "volunteer_signups_opportunity_id_idx" ON "volunteer_signups"("opportunity_id");

-- CreateIndex
CREATE UNIQUE INDEX "volunteer_signups_user_id_opportunity_id_key" ON "volunteer_signups"("user_id", "opportunity_id");

-- CreateIndex
CREATE INDEX "roster_shifts_user_id_date_idx" ON "roster_shifts"("user_id", "date");

-- CreateIndex
CREATE INDEX "roster_shifts_church_id_date_idx" ON "roster_shifts"("church_id", "date");

-- CreateIndex
CREATE INDEX "roster_shifts_opportunity_id_idx" ON "roster_shifts"("opportunity_id");

-- CreateIndex
CREATE INDEX "children_parent_id_idx" ON "children"("parent_id");

-- CreateIndex
CREATE INDEX "children_church_id_idx" ON "children"("church_id");

-- CreateIndex
CREATE INDEX "rooms_church_id_idx" ON "rooms"("church_id");

-- CreateIndex
CREATE INDEX "check_ins_child_id_idx" ON "check_ins"("child_id");

-- CreateIndex
CREATE INDEX "check_ins_room_id_idx" ON "check_ins"("room_id");

-- CreateIndex
CREATE INDEX "check_ins_parent_id_idx" ON "check_ins"("parent_id");

-- CreateIndex
CREATE INDEX "check_ins_security_code_idx" ON "check_ins"("security_code");

-- CreateIndex
CREATE INDEX "photo_albums_church_id_idx" ON "photo_albums"("church_id");

-- CreateIndex
CREATE INDEX "photo_albums_event_id_idx" ON "photo_albums"("event_id");

-- CreateIndex
CREATE INDEX "photos_album_id_idx" ON "photos"("album_id");

-- CreateIndex
CREATE INDEX "photos_church_id_idx" ON "photos"("church_id");

-- CreateIndex
CREATE INDEX "podcast_episodes_church_id_idx" ON "podcast_episodes"("church_id");

-- CreateIndex
CREATE INDEX "podcast_episodes_published_at_idx" ON "podcast_episodes"("published_at");

-- CreateIndex
CREATE UNIQUE INDEX "user_podcast_progress_user_id_episode_id_key" ON "user_podcast_progress"("user_id", "episode_id");

-- CreateIndex
CREATE INDEX "worship_songs_church_id_idx" ON "worship_songs"("church_id");

-- CreateIndex
CREATE INDEX "song_sections_song_id_idx" ON "song_sections"("song_id");

-- CreateIndex
CREATE INDEX "lyric_lines_section_id_idx" ON "lyric_lines"("section_id");

-- CreateIndex
CREATE INDEX "attendances_church_id_idx" ON "attendances"("church_id");

-- CreateIndex
CREATE INDEX "attendances_user_id_idx" ON "attendances"("user_id");

-- CreateIndex
CREATE INDEX "attendances_service_date_idx" ON "attendances"("service_date");

-- CreateIndex
CREATE UNIQUE INDEX "attendances_user_id_service_date_service_type_key" ON "attendances"("user_id", "service_date", "service_type");

-- CreateIndex
CREATE INDEX "spiritual_milestones_user_id_idx" ON "spiritual_milestones"("user_id");

-- CreateIndex
CREATE INDEX "spiritual_milestones_church_id_idx" ON "spiritual_milestones"("church_id");

-- CreateIndex
CREATE INDEX "saved_items_user_id_idx" ON "saved_items"("user_id");

-- CreateIndex
CREATE INDEX "saved_items_entity_type_entity_id_idx" ON "saved_items"("entity_type", "entity_id");

-- CreateIndex
CREATE UNIQUE INDEX "saved_items_user_id_entity_type_entity_id_key" ON "saved_items"("user_id", "entity_type", "entity_id");

-- AddForeignKey
ALTER TABLE "volunteer_opportunities" ADD CONSTRAINT "volunteer_opportunities_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "volunteer_signups" ADD CONSTRAINT "volunteer_signups_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "volunteer_signups" ADD CONSTRAINT "volunteer_signups_opportunity_id_fkey" FOREIGN KEY ("opportunity_id") REFERENCES "volunteer_opportunities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "roster_shifts" ADD CONSTRAINT "roster_shifts_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "roster_shifts" ADD CONSTRAINT "roster_shifts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "roster_shifts" ADD CONSTRAINT "roster_shifts_opportunity_id_fkey" FOREIGN KEY ("opportunity_id") REFERENCES "volunteer_opportunities"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "children" ADD CONSTRAINT "children_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "children" ADD CONSTRAINT "children_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rooms" ADD CONSTRAINT "rooms_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "check_ins" ADD CONSTRAINT "check_ins_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "check_ins" ADD CONSTRAINT "check_ins_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "rooms"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "check_ins" ADD CONSTRAINT "check_ins_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "check_ins" ADD CONSTRAINT "check_ins_checked_in_by_fkey" FOREIGN KEY ("checked_in_by") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photo_albums" ADD CONSTRAINT "photo_albums_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photo_albums" ADD CONSTRAINT "photo_albums_event_id_fkey" FOREIGN KEY ("event_id") REFERENCES "events"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photos" ADD CONSTRAINT "photos_album_id_fkey" FOREIGN KEY ("album_id") REFERENCES "photo_albums"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photos" ADD CONSTRAINT "photos_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "photos" ADD CONSTRAINT "photos_uploaded_by_id_fkey" FOREIGN KEY ("uploaded_by_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "podcast_episodes" ADD CONSTRAINT "podcast_episodes_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_podcast_progress" ADD CONSTRAINT "user_podcast_progress_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "user_podcast_progress" ADD CONSTRAINT "user_podcast_progress_episode_id_fkey" FOREIGN KEY ("episode_id") REFERENCES "podcast_episodes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "worship_songs" ADD CONSTRAINT "worship_songs_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "song_sections" ADD CONSTRAINT "song_sections_song_id_fkey" FOREIGN KEY ("song_id") REFERENCES "worship_songs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lyric_lines" ADD CONSTRAINT "lyric_lines_section_id_fkey" FOREIGN KEY ("section_id") REFERENCES "song_sections"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "attendances" ADD CONSTRAINT "attendances_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "spiritual_milestones" ADD CONSTRAINT "spiritual_milestones_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "spiritual_milestones" ADD CONSTRAINT "spiritual_milestones_church_id_fkey" FOREIGN KEY ("church_id") REFERENCES "churches"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "saved_items" ADD CONSTRAINT "saved_items_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
