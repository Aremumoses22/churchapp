/**
 * seed-api-data.ts
 * ────────────────────────────────────────────────────────────────
 * Adds rich, future-dated data for User, Sermon, and Event endpoints.
 * Updates existing sermons with audio/video URLs and thumbnails,
 * adds more sermons + series, future events with speakers, and
 * comprehensive user activity (saved sermons, progress, notes,
 * event registrations, attendance, milestones, saved items).
 *
 * Run with:  npx tsx prisma/seed-api-data.ts
 * ────────────────────────────────────────────────────────────────
 */

import { PrismaClient } from '../src/generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: resolve(__dirname, '../.env') });

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL! });
const prisma = new PrismaClient({ adapter });

// ── Placeholder media URLs (use free/public samples) ─────────
const AUDIO = {
  sample1: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
  sample2: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
  sample3: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
  sample4: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
  sample5: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
  sample6: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
};

const VIDEO = {
  sample1: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  sample2: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  sample3: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
};

const THUMB = {
  sermon1: 'https://images.unsplash.com/photo-1504052434569-70ad5836ab65?w=400&q=80',
  sermon2: 'https://images.unsplash.com/photo-1507692049790-de58290a4334?w=400&q=80',
  sermon3: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?w=400&q=80',
  sermon4: 'https://images.unsplash.com/photo-1499209974431-9dddcece7f88?w=400&q=80',
  sermon5: 'https://images.unsplash.com/photo-1529070538774-1843cb3265df?w=400&q=80',
  sermon6: 'https://images.unsplash.com/photo-1511367461989-f85a21fda167?w=400&q=80',
  series1: 'https://images.unsplash.com/photo-1508963493744-76fce69379c0?w=400&q=80',
  series2: 'https://images.unsplash.com/photo-1476900164809-ff19b8ae5968?w=400&q=80',
  series3: 'https://images.unsplash.com/photo-1519834584499-0ea6d0ad2f26?w=400&q=80',
  event1: 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=400&q=80',
  event2: 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=400&q=80',
  event3: 'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=400&q=80',
  event4: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=400&q=80',
  event5: 'https://images.unsplash.com/photo-1528605248644-14dd04022da1?w=400&q=80',
  event6: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400&q=80',
  speaker1: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&q=80',
  speaker2: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&q=80',
  speaker3: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&q=80',
  avatar: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&q=80',
};

async function seedApiData() {
  console.log('🌱 Seeding rich API data for User, Sermon & Event endpoints...\n');

  // ══════════════════════════════════════════════════════
  // 1. Fetch / create church and users
  // ══════════════════════════════════════════════════════

  const church = await prisma.church.findFirst({ where: { code: 'GRACE1' } });
  if (!church) {
    console.error('❌ Church not found. Run the main seed first: npm run db:seed');
    process.exit(1);
  }

  // Ensure test@gmail.com user exists (this is the user from the app)
  const testPasswordHash = await bcrypt.hash('Moses1234%', 12);
  const testUser = await prisma.user.upsert({
    where: { email: 'test@gmail.com' },
    update: {
      churchId: church.id,
      hasCompletedSetup: true,
      emailVerified: true,
      name: 'Moses Aremu',
      department: 'Media',
      bio: 'Flutter developer and worship enthusiast. Serving God through technology and creativity.',
      phone: '+234 812 345 6789',
      avatarUrl: THUMB.avatar,
      notificationPrefs: {
        pushEnabled: true,
        emailEnabled: true,
        events_push: true,
        events_email: true,
        sermons_push: true,
        sermons_email: true,
        giving_push: true,
        prayer_push: true,
        community_push: true,
        chat_push: true,
        system_push: true,
      },
    },
    create: {
      email: 'test@gmail.com',
      passwordHash: testPasswordHash,
      name: 'Moses Aremu',
      role: 'MEMBER',
      department: 'Media',
      bio: 'Flutter developer and worship enthusiast. Serving God through technology and creativity.',
      phone: '+234 812 345 6789',
      avatarUrl: THUMB.avatar,
      emailVerified: true,
      hasCompletedSetup: true,
      churchId: church.id,
      notificationPrefs: {
        pushEnabled: true,
        emailEnabled: true,
        events_push: true,
        events_email: true,
        sermons_push: true,
        sermons_email: true,
        giving_push: true,
        prayer_push: true,
        community_push: true,
        chat_push: true,
        system_push: true,
      },
    },
  });
  console.log(`  ✅ Test user: ${testUser.email} (password: Moses1234%)`);

  // Also fetch standard member
  const member = await prisma.user.findUnique({ where: { email: 'john@example.com' } });

  // ══════════════════════════════════════════════════════
  // 2. Update existing sermons with audio/video/thumbnails
  // ══════════════════════════════════════════════════════

  const existingSermons = await prisma.sermon.findMany({
    where: { churchId: church.id },
    orderBy: { date: 'asc' },
  });

  const audioSamples = Object.values(AUDIO);
  const videoSamples = Object.values(VIDEO);
  const thumbSamples = [THUMB.sermon1, THUMB.sermon2, THUMB.sermon3, THUMB.sermon4, THUMB.sermon5, THUMB.sermon6];

  for (let i = 0; i < existingSermons.length; i++) {
    await prisma.sermon.update({
      where: { id: existingSermons[i].id },
      data: {
        audioUrl: audioSamples[i % audioSamples.length],
        videoUrl: videoSamples[i % videoSamples.length],
        thumbnailUrl: thumbSamples[i % thumbSamples.length],
      },
    });
  }
  console.log(`  ✅ Updated ${existingSermons.length} existing sermons with audio/video/thumbnail URLs`);

  // Update existing series with images
  const existingSeries = await prisma.sermonSeries.findMany({ where: { churchId: church.id } });
  for (let i = 0; i < existingSeries.length; i++) {
    await prisma.sermonSeries.update({
      where: { id: existingSeries[i].id },
      data: { imageUrl: [THUMB.series1, THUMB.series2][i % 2] },
    });
  }
  console.log(`  ✅ Updated ${existingSeries.length} existing series with images`);

  // ══════════════════════════════════════════════════════
  // 3. Add new sermon series + sermons (recent dates, 2026)
  // ══════════════════════════════════════════════════════

  const series3 = await prisma.sermonSeries.create({
    data: {
      churchId: church.id,
      title: 'Kingdom Living',
      description: 'A powerful series on living out Kingdom principles in everyday life. Discover how to bring heaven to earth through your daily choices.',
      imageUrl: THUMB.series3,
      startDate: new Date('2026-02-01'),
      endDate: new Date('2026-03-08'),
      isActive: true,
      sortOrder: 3,
    },
  });
  console.log(`  ✅ New series: ${series3.title}`);

  const newSermons = await Promise.all([
    // Kingdom Living series
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series3.id,
        title: 'Citizens of Heaven',
        speaker: 'Pastor James',
        description: 'We are ambassadors of Christ, citizens of heaven living on earth. Learn what it means to carry your heavenly citizenship with authority and purpose.',
        date: new Date('2026-02-01'),
        duration: 2850,
        audioUrl: AUDIO.sample1,
        videoUrl: VIDEO.sample1,
        thumbnailUrl: THUMB.sermon1,
        scriptureRef: 'Philippians 3:20-21',
        tags: ['kingdom', 'citizenship', 'identity'],
        isFeatured: true,
        playCount: 320,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series3.id,
        title: 'Seeking First the Kingdom',
        speaker: 'Pastor James',
        description: 'Jesus taught us to seek first the Kingdom of God and His righteousness. What does this look like practically in our finances, relationships, and careers?',
        date: new Date('2026-02-08'),
        duration: 3100,
        audioUrl: AUDIO.sample2,
        videoUrl: VIDEO.sample2,
        thumbnailUrl: THUMB.sermon2,
        scriptureRef: 'Matthew 6:33',
        tags: ['kingdom', 'priorities', 'faith'],
        isFeatured: false,
        playCount: 245,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series3.id,
        title: 'Kingdom Authority',
        speaker: 'Minister Sarah',
        description: 'God has given believers authority to trample over serpents and scorpions. Understand the spiritual authority you carry as a child of God.',
        date: new Date('2026-02-15'),
        duration: 2700,
        audioUrl: AUDIO.sample3,
        videoUrl: VIDEO.sample3,
        thumbnailUrl: THUMB.sermon3,
        scriptureRef: 'Luke 10:19',
        tags: ['authority', 'power', 'spiritual warfare'],
        isFeatured: true,
        playCount: 189,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series3.id,
        title: 'The Salt and Light Mandate',
        speaker: 'Pastor James',
        description: 'You are the salt of the earth and the light of the world. This sermon explores how believers can impact culture, community, and the world around them.',
        date: new Date('2026-02-22'),
        duration: 2950,
        audioUrl: AUDIO.sample4,
        videoUrl: VIDEO.sample1,
        thumbnailUrl: THUMB.sermon4,
        scriptureRef: 'Matthew 5:13-16',
        tags: ['salt', 'light', 'influence', 'kingdom'],
        isFeatured: false,
        playCount: 156,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series3.id,
        title: 'Living by Kingdom Economics',
        speaker: 'Pastor Grace',
        description: 'The Kingdom of God operates on different principles than the world\'s economy. Discover the law of sowing and reaping, giving and receiving.',
        date: new Date('2026-03-01'),
        duration: 3200,
        audioUrl: AUDIO.sample5,
        videoUrl: VIDEO.sample2,
        thumbnailUrl: THUMB.sermon5,
        scriptureRef: 'Luke 6:38',
        tags: ['giving', 'generosity', 'kingdom economics'],
        isFeatured: true,
        playCount: 278,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series3.id,
        title: 'Kingdom Come — The Final Word',
        speaker: 'Pastor James',
        description: 'The closing message of our Kingdom Living series. We look at the Lord\'s Prayer — "Your Kingdom come, your will be done on earth as it is in heaven" — and what it means for us today.',
        date: new Date('2026-03-08'),
        duration: 3400,
        audioUrl: AUDIO.sample6,
        videoUrl: VIDEO.sample3,
        thumbnailUrl: THUMB.sermon6,
        scriptureRef: 'Matthew 6:9-13',
        tags: ['prayer', 'kingdom', 'will of God'],
        isFeatured: true,
        playCount: 410,
      },
    }),
    // Standalone recent sermons (not in a series)
    prisma.sermon.create({
      data: {
        churchId: church.id,
        title: 'The God Who Sees You',
        speaker: 'Pastor James',
        description: 'From the story of Hagar in Genesis, we learn that God sees us in our most desperate moments. He is El Roi — the God who sees. You are not invisible to Him.',
        date: new Date('2026-03-05'),
        duration: 2600,
        audioUrl: AUDIO.sample1,
        videoUrl: VIDEO.sample1,
        thumbnailUrl: THUMB.sermon1,
        scriptureRef: 'Genesis 16:13',
        tags: ['hope', 'comfort', 'identity'],
        isFeatured: false,
        playCount: 95,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        title: 'Breaking Every Chain',
        speaker: 'Minister Sarah',
        description: 'There is power in the name of Jesus to break every chain of bondage, addiction, fear, and depression. This sermon declares freedom over every area of your life.',
        date: new Date('2026-03-07'),
        duration: 2900,
        audioUrl: AUDIO.sample2,
        videoUrl: VIDEO.sample2,
        thumbnailUrl: THUMB.sermon2,
        scriptureRef: 'Isaiah 61:1-3',
        tags: ['freedom', 'deliverance', 'breakthrough'],
        isFeatured: true,
        playCount: 520,
      },
    }),
  ]);

  console.log(`  ✅ ${newSermons.length} new sermons created (6 in series + 2 standalone)`);

  // ══════════════════════════════════════════════════════
  // 4. Update existing events to future dates + add new events
  // ══════════════════════════════════════════════════════

  // Update existing events to 2026 dates so they show as upcoming
  const existingEvents = await prisma.event.findMany({
    where: { churchId: church.id },
    orderBy: { startDate: 'asc' },
  });

  const futureEventUpdates = [
    { startDate: new Date('2026-03-08T09:00:00Z'), endDate: new Date('2026-03-08T11:00:00Z'), imageUrl: THUMB.event1 },
    { startDate: new Date('2026-03-13T18:00:00Z'), endDate: new Date('2026-03-13T21:00:00Z'), imageUrl: THUMB.event2 },
    { startDate: new Date('2026-03-20T09:00:00Z'), endDate: new Date('2026-03-22T17:00:00Z'), imageUrl: THUMB.event3 },
    { startDate: new Date('2026-03-28T08:00:00Z'), endDate: new Date('2026-03-28T14:00:00Z'), imageUrl: THUMB.event4 },
    { startDate: new Date('2026-04-10T15:00:00Z'), endDate: new Date('2026-04-12T12:00:00Z'), imageUrl: THUMB.event5 },
  ];

  for (let i = 0; i < Math.min(existingEvents.length, futureEventUpdates.length); i++) {
    await prisma.event.update({
      where: { id: existingEvents[i].id },
      data: futureEventUpdates[i],
    });
  }
  console.log(`  ✅ Updated ${Math.min(existingEvents.length, futureEventUpdates.length)} existing events to future dates with images`);

  // Add new future events
  const newEvents = await Promise.all([
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Easter Celebration Service',
        description: 'Join us for a glorious Easter celebration! Special worship, drama, and a powerful message of resurrection hope. Invite your friends and family.',
        category: 'worship',
        imageUrl: THUMB.event1,
        location: 'Main Auditorium',
        startDate: new Date('2026-04-05T08:00:00Z'),
        endDate: new Date('2026-04-05T12:00:00Z'),
        registrationRequired: false,
        isFeatured: true,
        tags: ['easter', 'celebration', 'worship'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Women\'s Conference 2026',
        description: 'Empowered to Lead — A two-day conference for women of all ages. Featuring worship, breakout sessions, and networking opportunities with women leaders.',
        category: 'conference',
        imageUrl: THUMB.event2,
        location: 'Conference Center',
        startDate: new Date('2026-04-17T09:00:00Z'),
        endDate: new Date('2026-04-18T17:00:00Z'),
        registrationRequired: true,
        maxCapacity: 300,
        registeredCount: 87,
        isFeatured: true,
        tags: ['women', 'conference', 'leadership'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Youth Game Night',
        description: 'A fun evening of games, food, and fellowship for teens and young adults. Bring your friends!',
        category: 'youth',
        imageUrl: THUMB.event3,
        location: 'Youth Center',
        startDate: new Date('2026-03-14T17:00:00Z'),
        endDate: new Date('2026-03-14T21:00:00Z'),
        registrationRequired: true,
        maxCapacity: 80,
        registeredCount: 32,
        isFeatured: false,
        tags: ['youth', 'games', 'fellowship'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Prayer & Fasting Week',
        description: 'Join us for a week of corporate prayer and fasting. Evening prayer meetings from Monday to Friday with special topics each night.',
        category: 'prayer',
        imageUrl: THUMB.event4,
        location: 'Sanctuary',
        startDate: new Date('2026-03-16T06:00:00Z'),
        endDate: new Date('2026-03-20T20:00:00Z'),
        registrationRequired: false,
        isFeatured: true,
        tags: ['prayer', 'fasting', 'revival'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Community Clean-Up Day',
        description: 'Be the hands and feet of Jesus in our neighborhood. We\'ll clean public spaces, paint fences, and distribute care packages.',
        category: 'outreach',
        imageUrl: THUMB.event5,
        location: 'Meeting point: Church Parking Lot',
        startDate: new Date('2026-04-25T07:00:00Z'),
        endDate: new Date('2026-04-25T13:00:00Z'),
        registrationRequired: true,
        maxCapacity: 60,
        registeredCount: 18,
        isFeatured: false,
        tags: ['outreach', 'community', 'service'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Couples\' Date Night',
        description: 'A special evening for married couples — dinner, worship, and a short teaching on building a God-centered marriage.',
        category: 'fellowship',
        imageUrl: THUMB.event6,
        location: 'Fellowship Hall',
        startDate: new Date('2026-03-21T18:00:00Z'),
        endDate: new Date('2026-03-21T21:30:00Z'),
        registrationRequired: true,
        maxCapacity: 50,
        registeredCount: 14,
        isFeatured: true,
        tags: ['couples', 'marriage', 'fellowship'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Midweek Bible Study',
        description: 'Deep dive into the Book of Romans. Open to all. Bring your Bible and a hunger for the Word.',
        category: 'fellowship',
        imageUrl: THUMB.event1,
        location: 'Library Room',
        startDate: new Date('2026-03-11T18:00:00Z'),
        endDate: new Date('2026-03-11T20:00:00Z'),
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=WE',
        registrationRequired: false,
        isFeatured: false,
        tags: ['bible study', 'midweek', 'romans'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Worship Night Live',
        description: 'An evening of uninterrupted worship. No sermon, no program — just worship. Come and experience the presence of God in a powerful way.',
        category: 'worship',
        imageUrl: THUMB.event2,
        location: 'Main Auditorium',
        startDate: new Date('2026-03-27T19:00:00Z'),
        endDate: new Date('2026-03-27T22:00:00Z'),
        registrationRequired: false,
        isFeatured: true,
        tags: ['worship', 'night', 'presence'],
      },
    }),
  ]);

  // Add speakers to new events
  await prisma.eventSpeaker.createMany({
    data: [
      // Easter
      { eventId: newEvents[0].id, name: 'Pastor James', title: 'Senior Pastor', imageUrl: THUMB.speaker1, sortOrder: 1 },
      { eventId: newEvents[0].id, name: 'Minister Sarah', title: 'Worship Director', imageUrl: THUMB.speaker2, sortOrder: 2 },
      // Women's Conference
      { eventId: newEvents[1].id, name: 'Pastor Grace Adeyemi', title: 'Associate Pastor', imageUrl: THUMB.speaker2, sortOrder: 1 },
      { eventId: newEvents[1].id, name: 'Dr. Tolu Johnson', title: 'Guest Speaker — Author & Life Coach', imageUrl: THUMB.speaker3, sortOrder: 2 },
      // Prayer & Fasting
      { eventId: newEvents[3].id, name: 'Pastor James', title: 'Senior Pastor', imageUrl: THUMB.speaker1, sortOrder: 1 },
      // Couples Date Night
      { eventId: newEvents[5].id, name: 'Pastor James', title: 'Senior Pastor', imageUrl: THUMB.speaker1, sortOrder: 1 },
      { eventId: newEvents[5].id, name: 'Pastor Grace Adeyemi', title: 'Associate Pastor', imageUrl: THUMB.speaker2, sortOrder: 2 },
      // Worship Night
      { eventId: newEvents[7].id, name: 'Minister Sarah', title: 'Worship Director', imageUrl: THUMB.speaker2, sortOrder: 1 },
    ],
  });

  console.log(`  ✅ ${newEvents.length} new future events + speakers created`);

  // ══════════════════════════════════════════════════════
  // 5. User activity for test@gmail.com
  // ══════════════════════════════════════════════════════

  const allSermons = await prisma.sermon.findMany({
    where: { churchId: church.id },
    orderBy: { date: 'desc' },
  });

  // Saved sermons (save a few)
  for (const sermon of allSermons.slice(0, 5)) {
    await prisma.savedSermon.upsert({
      where: { userId_sermonId: { userId: testUser.id, sermonId: sermon.id } },
      update: {},
      create: { userId: testUser.id, sermonId: sermon.id },
    });
  }
  console.log('  ✅ 5 sermons saved for test user');

  // Sermon progress (partially listened)
  const progressData = [
    { sermonIdx: 0, position: 1800, completed: false },
    { sermonIdx: 1, position: 2700, completed: true },
    { sermonIdx: 2, position: 900, completed: false },
    { sermonIdx: 4, position: 3200, completed: true },
  ];

  for (const p of progressData) {
    const s = allSermons[p.sermonIdx];
    if (!s) continue;
    await prisma.userSermonProgress.upsert({
      where: { userId_sermonId: { userId: testUser.id, sermonId: s.id } },
      update: { position: p.position, completed: p.completed, lastPlayedAt: new Date() },
      create: { userId: testUser.id, sermonId: s.id, position: p.position, completed: p.completed, lastPlayedAt: new Date() },
    });
  }
  console.log('  ✅ Sermon progress for 4 sermons');

  // Sermon notes
  const notesData = [
    { sermonIdx: 0, content: 'Powerful message about breaking free from every chain. Key point: Freedom starts with declaring the truth of God\'s Word over your life.\n\n"The Spirit of the Sovereign LORD is on me, because the LORD has anointed me to proclaim good news to the poor." — Isaiah 61:1\n\nAction steps:\n1. Identify areas of bondage\n2. Find Scriptures that speak to those areas\n3. Declare them daily\n4. Surround yourself with believers who will stand with you' },
    { sermonIdx: 2, content: 'Kingdom authority is something every believer has been given. We don\'t need to beg for authority — Jesus already delegated it to us.\n\nLuke 10:19 — "I have given you authority to trample on snakes and scorpions..."\n\nThis doesn\'t mean we won\'t face challenges. It means we have the authority to overcome them!' },
    { sermonIdx: 5, content: 'The Lord\'s Prayer is not just a prayer to recite — it\'s a model for how to pray. "Your Kingdom come, Your will be done" should be the cry of every believer\'s heart.' },
  ];

  for (const n of notesData) {
    const s = allSermons[n.sermonIdx];
    if (!s) continue;
    await prisma.userSermonNote.upsert({
      where: { userId_sermonId: { userId: testUser.id, sermonId: s.id } },
      update: { content: n.content },
      create: { userId: testUser.id, sermonId: s.id, content: n.content },
    });
  }
  console.log('  ✅ Sermon notes for 3 sermons');

  // Event registrations for test user
  const allEvents = await prisma.event.findMany({
    where: { churchId: church.id, registrationRequired: true },
    orderBy: { startDate: 'asc' },
  });

  for (const event of allEvents.slice(0, 3)) {
    await prisma.eventRegistration.upsert({
      where: { userId_eventId: { userId: testUser.id, eventId: event.id } },
      update: { status: 'REGISTERED' },
      create: { userId: testUser.id, eventId: event.id, status: 'REGISTERED' },
    });
    // bump registered count
    await prisma.event.update({
      where: { id: event.id },
      data: { registeredCount: { increment: 1 } },
    });
  }
  console.log(`  ✅ Registered test user for ${Math.min(3, allEvents.length)} events`);

  // ── Attendance records ─────────────────────────────
  const attendanceDates = [
    { date: '2026-02-01', type: 'SUNDAY' },
    { date: '2026-02-08', type: 'SUNDAY' },
    { date: '2026-02-11', type: 'MIDWEEK' },
    { date: '2026-02-15', type: 'SUNDAY' },
    { date: '2026-02-18', type: 'MIDWEEK' },
    { date: '2026-02-22', type: 'SUNDAY' },
    { date: '2026-03-01', type: 'SUNDAY' },
    { date: '2026-03-04', type: 'MIDWEEK' },
    { date: '2026-03-07', type: 'SPECIAL' },
  ];

  for (const a of attendanceDates) {
    try {
      await prisma.attendance.create({
        data: {
          userId: testUser.id,
          churchId: church.id,
          serviceDate: new Date(a.date),
          serviceType: a.type as any,
          checkinMethod: 'MANUAL',
        },
      });
    } catch { /* ignore duplicate */ }
  }
  console.log(`  ✅ ${attendanceDates.length} attendance records for test user`);

  // ── Spiritual milestones ───────────────────────────
  const milestones = [
    { type: 'SALVATION', title: 'Gave my Life to Christ', description: 'Accepted Jesus as Lord and Savior', achievedAt: new Date('2020-12-25') },
    { type: 'BAPTISM', title: 'Water Baptism', description: 'Baptized at Grace Community Church', achievedAt: new Date('2021-03-28') },
    { type: 'FIRST_SERVE', title: 'First Volunteer Service', description: 'Joined the Media team', achievedAt: new Date('2021-06-15') },
    { type: 'SMALL_GROUP', title: 'Joined a Connect Group', description: 'Member of Men of Valor group', achievedAt: new Date('2021-09-01') },
    { type: 'FIRST_GIVE', title: 'First Tithe & Offering', description: 'Started faithful giving', achievedAt: new Date('2021-01-10') },
    { type: 'ONE_YEAR', title: 'One Year Anniversary', description: 'Celebrating one year at Grace Community', achievedAt: new Date('2021-12-25') },
  ];

  for (const m of milestones) {
    try {
      await prisma.spiritualMilestone.create({
        data: {
          userId: testUser.id,
          churchId: church.id,
          type: m.type,
          title: m.title,
          description: m.description,
          achievedAt: m.achievedAt,
        },
      });
    } catch { /* ignore duplicate */ }
  }
  console.log(`  ✅ ${milestones.length} spiritual milestones`);

  // ── Saved items ────────────────────────────────────
  const savedItemsData = [
    { entityType: 'SERMON' as const, entityId: allSermons[0]?.id },
    { entityType: 'SERMON' as const, entityId: allSermons[2]?.id },
    { entityType: 'EVENT' as const, entityId: newEvents[0]?.id },
    { entityType: 'EVENT' as const, entityId: newEvents[3]?.id },
  ].filter((s) => s.entityId);

  for (const item of savedItemsData) {
    try {
      await prisma.savedItem.create({
        data: {
          userId: testUser.id,
          entityType: item.entityType,
          entityId: item.entityId!,
        },
      });
    } catch { /* ignore duplicate */ }
  }
  console.log(`  ✅ ${savedItemsData.length} saved items`);

  // ══════════════════════════════════════════════════════
  // 6. Also add activity for john@example.com member
  // ══════════════════════════════════════════════════════

  if (member) {
    // Add audio/video progress for member too
    for (const sermon of allSermons.slice(0, 3)) {
      await prisma.savedSermon.upsert({
        where: { userId_sermonId: { userId: member.id, sermonId: sermon.id } },
        update: {},
        create: { userId: member.id, sermonId: sermon.id },
      });
    }

    // Register member for some new events
    for (const event of allEvents.slice(1, 4)) {
      try {
        await prisma.eventRegistration.upsert({
          where: { userId_eventId: { userId: member.id, eventId: event.id } },
          update: { status: 'REGISTERED' },
          create: { userId: member.id, eventId: event.id, status: 'REGISTERED' },
        });
      } catch { /* ignore */ }
    }
    console.log('  ✅ Additional activity for john@example.com');
  }

  // ══════════════════════════════════════════════════════
  // SUMMARY
  // ══════════════════════════════════════════════════════

  const totalSermons = await prisma.sermon.count({ where: { churchId: church.id } });
  const totalEvents = await prisma.event.count({ where: { churchId: church.id } });
  const totalSeries = await prisma.sermonSeries.count({ where: { churchId: church.id } });
  const totalUsers = await prisma.user.count({ where: { churchId: church.id } });

  console.log('\n' + '═'.repeat(50));
  console.log('📊 Database Summary:');
  console.log('═'.repeat(50));
  console.log(`  Users:     ${totalUsers}`);
  console.log(`  Series:    ${totalSeries}`);
  console.log(`  Sermons:   ${totalSermons}`);
  console.log(`  Events:    ${totalEvents}`);
  console.log('═'.repeat(50));
  console.log('\n✅ Test accounts:');
  console.log('  admin@gracecommunity.app / Admin@123');
  console.log('  john@example.com / Member@123');
  console.log('  test@gmail.com / Moses1234%');
  console.log('\n🎉 API seed data complete!\n');
}

seedApiData()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
