import { PrismaClient } from '../src/generated/prisma/client';
import { PrismaPg } from '@prisma/adapter-pg';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

dotenv.config({ path: resolve(__dirname, '../.env') });

const adapter = new PrismaPg({
  connectionString: process.env.DATABASE_URL!,
});

const prisma = new PrismaClient({ adapter });

async function seed() {
  console.log('🌱 Seeding database...\n');

  // ══════════════════════════════════════════════════════
  // PHASE 1: Church + Users
  // ══════════════════════════════════════════════════════

  const church = await prisma.church.upsert({
    where: { code: 'GRACE1' },
    update: {},
    create: {
      name: 'Grace Community Church',
      tagline: 'Est. 1998 · Reaching the world for Christ',
      code: 'GRACE1',
      mission: 'To know God and make Him known.',
      vision: 'A Christ-centered community transforming lives through faith, hope, and love.',
      ein: '12-3456789',
      phone: '+1 (555) 123-4567',
      email: 'info@gracecommunity.app',
      website: 'https://gracecommunity.app',
      address: '123 Faith Avenue, Lagos, Nigeria',
      socialLinks: {
        facebook: 'https://facebook.com/gracecommunity',
        instagram: 'https://instagram.com/gracecommunity',
        youtube: 'https://youtube.com/@gracecommunity',
        twitter: 'https://twitter.com/gracecommunity',
      },
      settings: {
        primaryColor: '#6C63FF',
        accentColor: '#FF6584',
        features: {
          giving: true,
          forum: true,
          chat: true,
          liveService: true,
          kidsCheckin: true,
        },
        timeline: [
          { year: '1998', title: 'The Beginning', description: 'Started as a small Bible study group of 12 people meeting in a living room.' },
          { year: '2003', title: 'First Building', description: 'Moved into our first church building with 150 members.' },
          { year: '2010', title: 'Community Expansion', description: 'Launched outreach programs and grew to over 800 members.' },
          { year: '2018', title: 'Multi-Campus', description: 'Opened our second and third campuses to reach more communities.' },
          { year: '2024', title: 'Digital Ministry', description: 'Launched online services and this app to connect with members worldwide.' },
        ],
      },
    },
  });
  console.log(`  ✅ Church: ${church.name} (code: ${church.code})`);

  // ── Super Admin (platform-level, no churchId) ─────────────────
  const superAdminHash = await bcrypt.hash('SuperAdmin@123', 12);
  const superAdmin = await prisma.user.upsert({
    where: { email: 'superadmin@churchapp.com' },
    update: {},
    create: {
      email: 'superadmin@churchapp.com',
      passwordHash: superAdminHash,
      name: 'Super Admin',
      role: 'SUPER_ADMIN',
      emailVerified: true,
      hasCompletedSetup: true,
      churchId: null,
    },
  });
  console.log(`  ✅ Super Admin: ${superAdmin.email} (password: SuperAdmin@123)`);

  const adminPasswordHash = await bcrypt.hash('Admin@123', 12);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@gracecommunity.app' },
    update: {},
    create: {
      email: 'admin@gracecommunity.app',
      passwordHash: adminPasswordHash,
      name: 'Pastor James',
      role: 'ADMIN',
      department: 'Senior Pastor',
      bio: 'Senior Pastor at Grace Community Church. Passionate about reaching souls for Christ.',
      emailVerified: true,
      hasCompletedSetup: true,
      churchId: church.id,
      notificationPrefs: {
        pushEnabled: true,
        emailEnabled: true,
        sermons: true,
        events: true,
        live: true,
        chat: true,
        giving: true,
        prayer: true,
        announcements: true,
      },
    },
  });
  console.log(`  ✅ Admin: ${admin.email} (password: Admin@123)`);

  const memberPasswordHash = await bcrypt.hash('Member@123', 12);
  const member = await prisma.user.upsert({
    where: { email: 'john@example.com' },
    update: {},
    create: {
      email: 'john@example.com',
      passwordHash: memberPasswordHash,
      name: 'John Doe',
      role: 'MEMBER',
      department: 'Media',
      bio: 'Worshipper. Media team volunteer.',
      emailVerified: true,
      hasCompletedSetup: true,
      churchId: church.id,
      notificationPrefs: {
        pushEnabled: true,
        emailEnabled: true,
        sermons: true,
        events: true,
        live: true,
        chat: true,
      },
    },
  });
  console.log(`  ✅ Member: ${member.email} (password: Member@123)`);

  // ══════════════════════════════════════════════════════
  // PHASE 2: Sermon Series + Sermons
  // ══════════════════════════════════════════════════════

  const series1 = await prisma.sermonSeries.create({
    data: {
      churchId: church.id,
      title: 'Unshakeable Faith',
      description: 'A 4-part series exploring what it means to build your life on the rock of Christ.',
      startDate: new Date('2025-01-05'),
      endDate: new Date('2025-01-26'),
      isActive: true,
      sortOrder: 1,
    },
  });

  const series2 = await prisma.sermonSeries.create({
    data: {
      churchId: church.id,
      title: 'The Power of Prayer',
      description: 'Discover the transformative power of persistent, faith-filled prayer.',
      startDate: new Date('2025-02-02'),
      isActive: true,
      sortOrder: 2,
    },
  });

  console.log(`  ✅ Sermon Series: ${series1.title}, ${series2.title}`);

  const sermons = await Promise.all([
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series1.id,
        title: 'Foundation of Faith',
        speaker: 'Pastor James',
        description: 'Discover the unshakeable foundation that withstands every storm of life.',
        date: new Date('2025-01-05'),
        duration: 2700,
        scriptureRef: 'Matthew 7:24-27',
        tags: ['faith', 'foundation', 'storms'],
        isFeatured: true,
        playCount: 142,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series1.id,
        title: 'When Doubt Creeps In',
        speaker: 'Pastor James',
        description: 'How to overcome doubt and stand firm when everything around you shakes.',
        date: new Date('2025-01-12'),
        duration: 3120,
        scriptureRef: 'James 1:2-8',
        tags: ['doubt', 'faith', 'perseverance'],
        playCount: 98,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series1.id,
        title: 'Faith That Moves Mountains',
        speaker: 'Pastor Grace',
        description: 'Exploring the mustard seed faith that can accomplish the impossible.',
        date: new Date('2025-01-19'),
        duration: 2880,
        scriptureRef: 'Matthew 17:20',
        tags: ['faith', 'mountains', 'impossible'],
        isFeatured: true,
        playCount: 76,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series1.id,
        title: 'Standing Strong Together',
        speaker: 'Pastor James',
        description: 'The importance of community in building and sustaining unshakeable faith.',
        date: new Date('2025-01-26'),
        duration: 2640,
        scriptureRef: 'Hebrews 10:24-25',
        tags: ['faith', 'community', 'encouragement'],
        playCount: 54,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series2.id,
        title: 'Prayer Changes Everything',
        speaker: 'Pastor James',
        description: 'An introduction to the life-transforming power of prayer.',
        date: new Date('2025-02-02'),
        duration: 3000,
        scriptureRef: 'Philippians 4:6-7',
        tags: ['prayer', 'peace', 'anxiety'],
        isFeatured: true,
        playCount: 210,
      },
    }),
    prisma.sermon.create({
      data: {
        churchId: church.id,
        seriesId: series2.id,
        title: 'Praying Without Ceasing',
        speaker: 'Minister Sarah',
        description: 'What does it mean to pray without ceasing in our daily lives?',
        date: new Date('2025-02-09'),
        duration: 2520,
        scriptureRef: '1 Thessalonians 5:16-18',
        tags: ['prayer', 'daily', 'discipline'],
        playCount: 165,
      },
    }),
  ]);

  console.log(`  ✅ Sermons: ${sermons.length} sermons created`);

  // ══════════════════════════════════════════════════════
  // PHASE 2: Events
  // ══════════════════════════════════════════════════════

  const events = await Promise.all([
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Sunday Worship Service',
        description: 'Join us for our regular Sunday worship experience. All are welcome!',
        category: 'worship',
        location: 'Main Auditorium',
        startDate: new Date('2025-03-02T09:00:00Z'),
        endDate: new Date('2025-03-02T11:00:00Z'),
        isRecurring: true,
        recurrenceRule: 'FREQ=WEEKLY;BYDAY=SU',
        isFeatured: true,
        tags: ['worship', 'weekly'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Night of Worship & Prayer',
        description: 'A special evening dedicated to worship and corporate prayer. Come encounter God\'s presence.',
        category: 'prayer',
        location: 'Main Auditorium',
        startDate: new Date('2025-03-07T18:00:00Z'),
        endDate: new Date('2025-03-07T21:00:00Z'),
        registrationRequired: true,
        maxCapacity: 500,
        isFeatured: true,
        tags: ['prayer', 'worship', 'special'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Youth Conference 2025',
        description: 'Three-day youth conference with worship, workshops, and fellowship.',
        category: 'youth',
        location: 'Youth Center',
        startDate: new Date('2025-03-14T09:00:00Z'),
        endDate: new Date('2025-03-16T17:00:00Z'),
        registrationRequired: true,
        maxCapacity: 200,
        tags: ['youth', 'conference'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Community Outreach Day',
        description: 'Join us as we serve our local community through various outreach projects.',
        category: 'outreach',
        location: 'Various Locations',
        startDate: new Date('2025-03-22T08:00:00Z'),
        endDate: new Date('2025-03-22T14:00:00Z'),
        registrationRequired: true,
        maxCapacity: 100,
        tags: ['outreach', 'community', 'service'],
      },
    }),
    prisma.event.create({
      data: {
        churchId: church.id,
        title: 'Marriage Retreat Weekend',
        description: 'A weekend getaway for couples to strengthen their marriage and grow together in faith.',
        category: 'fellowship',
        location: 'Lakeside Resort',
        startDate: new Date('2025-04-04T15:00:00Z'),
        endDate: new Date('2025-04-06T12:00:00Z'),
        registrationRequired: true,
        maxCapacity: 40,
        tags: ['marriage', 'retreat', 'couples'],
      },
    }),
  ]);

  // Add speakers to events
  await prisma.eventSpeaker.createMany({
    data: [
      { eventId: events[1].id, name: 'Pastor James', title: 'Senior Pastor', sortOrder: 1 },
      { eventId: events[1].id, name: 'Minister Sarah', title: 'Worship Director', sortOrder: 2 },
      { eventId: events[2].id, name: 'Youth Pastor David', title: 'Youth Ministry Director', sortOrder: 1 },
      { eventId: events[4].id, name: 'Pastor James', title: 'Senior Pastor', sortOrder: 1 },
      { eventId: events[4].id, name: 'Sister Grace', title: 'Marriage Counselor', sortOrder: 2 },
    ],
  });

  console.log(`  ✅ Events: ${events.length} events + speakers created`);

  // ══════════════════════════════════════════════════════
  // PHASE 2: Bible Books + Sample Verses
  // ══════════════════════════════════════════════════════

  const bibleBooks = [
    // Old Testament
    { name: 'Genesis', abbreviation: 'Gen', testament: 'OT' as const, bookOrder: 1, chapterCount: 50 },
    { name: 'Exodus', abbreviation: 'Exod', testament: 'OT' as const, bookOrder: 2, chapterCount: 40 },
    { name: 'Psalms', abbreviation: 'Ps', testament: 'OT' as const, bookOrder: 19, chapterCount: 150 },
    { name: 'Proverbs', abbreviation: 'Prov', testament: 'OT' as const, bookOrder: 20, chapterCount: 31 },
    { name: 'Isaiah', abbreviation: 'Isa', testament: 'OT' as const, bookOrder: 23, chapterCount: 66 },
    { name: 'Jeremiah', abbreviation: 'Jer', testament: 'OT' as const, bookOrder: 24, chapterCount: 52 },
    // New Testament
    { name: 'Matthew', abbreviation: 'Matt', testament: 'NT' as const, bookOrder: 40, chapterCount: 28 },
    { name: 'John', abbreviation: 'John', testament: 'NT' as const, bookOrder: 43, chapterCount: 21 },
    { name: 'Romans', abbreviation: 'Rom', testament: 'NT' as const, bookOrder: 45, chapterCount: 16 },
    { name: 'Philippians', abbreviation: 'Phil', testament: 'NT' as const, bookOrder: 50, chapterCount: 4 },
    { name: 'Hebrews', abbreviation: 'Heb', testament: 'NT' as const, bookOrder: 58, chapterCount: 13 },
    { name: 'Revelation', abbreviation: 'Rev', testament: 'NT' as const, bookOrder: 66, chapterCount: 22 },
  ];

  const createdBooks: Record<string, string> = {}; // name -> id
  for (const book of bibleBooks) {
    const created = await prisma.bibleBook.upsert({
      where: { bookOrder: book.bookOrder },
      update: {},
      create: book,
    });
    createdBooks[book.name] = created.id;
  }

  console.log(`  ✅ Bible Books: ${bibleBooks.length} books created`);

  // Add sample verses (John 3:16-18, Psalm 23:1-6, Romans 8:28)
  const sampleVerses = [
    // John 3
    { bookId: createdBooks['John'], chapter: 3, verse: 16, text: 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.' },
    { bookId: createdBooks['John'], chapter: 3, verse: 17, text: 'For God did not send his Son into the world to condemn the world, but to save the world through him.' },
    { bookId: createdBooks['John'], chapter: 3, verse: 18, text: 'Whoever believes in him is not condemned, but whoever does not believe stands condemned already because they have not believed in the name of God\'s one and only Son.' },
    // Psalm 23
    { bookId: createdBooks['Psalms'], chapter: 23, verse: 1, text: 'The LORD is my shepherd, I lack nothing.' },
    { bookId: createdBooks['Psalms'], chapter: 23, verse: 2, text: 'He makes me lie down in green pastures, he leads me beside quiet waters,' },
    { bookId: createdBooks['Psalms'], chapter: 23, verse: 3, text: 'he refreshes my soul. He guides me along the right paths for his name\'s sake.' },
    { bookId: createdBooks['Psalms'], chapter: 23, verse: 4, text: 'Even though I walk through the darkest valley, I will fear no evil, for you are with me; your rod and your staff, they comfort me.' },
    { bookId: createdBooks['Psalms'], chapter: 23, verse: 5, text: 'You prepare a table before me in the presence of my enemies. You anoint my head with oil; my cup overflows.' },
    { bookId: createdBooks['Psalms'], chapter: 23, verse: 6, text: 'Surely your goodness and love will follow me all the days of my life, and I will dwell in the house of the LORD forever.' },
    // Romans 8
    { bookId: createdBooks['Romans'], chapter: 8, verse: 28, text: 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.' },
    { bookId: createdBooks['Romans'], chapter: 8, verse: 31, text: 'What, then, shall we say in response to these things? If God is for us, who can be against us?' },
    { bookId: createdBooks['Romans'], chapter: 8, verse: 37, text: 'No, in all these things we are more than conquerors through him who loved us.' },
    { bookId: createdBooks['Romans'], chapter: 8, verse: 38, text: 'For I am convinced that neither death nor life, neither angels nor demons, neither the present nor the future, nor any powers,' },
    { bookId: createdBooks['Romans'], chapter: 8, verse: 39, text: 'neither height nor depth, nor anything else in all creation, will be able to separate us from the love of God that is in Christ Jesus our Lord.' },
    // Philippians 4
    { bookId: createdBooks['Philippians'], chapter: 4, verse: 6, text: 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God.' },
    { bookId: createdBooks['Philippians'], chapter: 4, verse: 7, text: 'And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.' },
    { bookId: createdBooks['Philippians'], chapter: 4, verse: 13, text: 'I can do all this through him who gives me strength.' },
    // Proverbs 3
    { bookId: createdBooks['Proverbs'], chapter: 3, verse: 5, text: 'Trust in the LORD with all your heart and lean not on your own understanding;' },
    { bookId: createdBooks['Proverbs'], chapter: 3, verse: 6, text: 'in all your ways submit to him, and he will make your paths straight.' },
    // Isaiah 40
    { bookId: createdBooks['Isaiah'], chapter: 40, verse: 31, text: 'But those who hope in the LORD will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.' },
    // Matthew 11
    { bookId: createdBooks['Matthew'], chapter: 11, verse: 28, text: 'Come to me, all you who are weary and burdened, and I will give you rest.' },
    // Hebrews 11
    { bookId: createdBooks['Hebrews'], chapter: 11, verse: 1, text: 'Now faith is confidence in what we hope for and assurance about what we do not see.' },
    // Genesis 1
    { bookId: createdBooks['Genesis'], chapter: 1, verse: 1, text: 'In the beginning God created the heavens and the earth.' },
    { bookId: createdBooks['Genesis'], chapter: 1, verse: 27, text: 'So God created mankind in his own image, in the image of God he created them; male and female he created them.' },
  ];

  // Upsert verses to be idempotent
  for (const v of sampleVerses) {
    await prisma.bibleVerse.upsert({
      where: { bookId_chapter_verse: { bookId: v.bookId, chapter: v.chapter, verse: v.verse } },
      update: {},
      create: v,
    });
  }

  console.log(`  ✅ Bible Verses: ${sampleVerses.length} sample verses created`);

  // ══════════════════════════════════════════════════════
  // PHASE 2: Devotionals
  // ══════════════════════════════════════════════════════

  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const devotionals = [];
  const devotionalData = [
    {
      title: 'Walking in Trust',
      content: 'Trusting God is more than a one-time decision. It\'s a daily choice to surrender our plans and fears to Him. Proverbs 3:5-6 reminds us to trust with ALL our heart — not just the parts that feel comfortable.\n\nToday, consider the areas of your life where you\'re still trying to maintain control. What would it look like to fully trust God with those areas?\n\nPrayer: Lord, I surrender my plans to You. Help me trust You more deeply each day. Amen.',
      scriptureRef: 'Proverbs 3:5-6',
      scriptureText: 'Trust in the LORD with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
      authorName: 'Pastor James',
    },
    {
      title: 'Rest for the Weary',
      content: 'In a world that glorifies hustle and productivity, Jesus offers something radically different — rest. But this isn\'t laziness; it\'s a deep spiritual rest that comes from knowing God is in control.\n\nWhen you feel overwhelmed by the demands of life, remember that Jesus invites you to come to Him. His yoke is easy, and His burden is light.\n\nPrayer: Jesus, I come to You today weary and burdened. I receive Your rest and peace. Amen.',
      scriptureRef: 'Matthew 11:28-30',
      scriptureText: 'Come to me, all you who are weary and burdened, and I will give you rest. Take my yoke upon you and learn from me, for I am gentle and humble in heart, and you will find rest for your souls.',
      authorName: 'Minister Sarah',
    },
    {
      title: 'More Than Conquerors',
      content: 'Life will throw challenges at us — financial pressures, health scares, broken relationships. But Paul reminds us that NONE of these things can separate us from God\'s love.\n\nYou are not just surviving — you are MORE than a conqueror through Christ. Today, walk in that truth. The battle is already won.\n\nPrayer: Father, help me remember that I am more than a conqueror through Your love. Nothing can separate me from You. Amen.',
      scriptureRef: 'Romans 8:37-39',
      scriptureText: 'No, in all these things we are more than conquerors through him who loved us.',
      authorName: 'Pastor James',
    },
    {
      title: 'Peace Beyond Understanding',
      content: 'Anxiety is one of the greatest struggles of our generation. But God offers us a peace that doesn\'t make sense to the world — a peace that guards our hearts and minds even in chaos.\n\nThe prescription is simple: pray about everything, worry about nothing, and thank God for all things.\n\nPrayer: Lord, I bring my anxieties to You today. Replace my worry with Your supernatural peace. Amen.',
      scriptureRef: 'Philippians 4:6-7',
      scriptureText: 'Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.',
      authorName: 'Sister Grace',
    },
    {
      title: 'Strength Renewed',
      content: 'Waiting on God is not passive — it\'s an active posture of trust and expectation. When we wait on the Lord, we position ourselves to receive supernatural strength.\n\nAre you in a season of waiting? Don\'t lose heart. God is preparing something beautiful. Keep your eyes on Him.\n\nPrayer: God, I wait on You today. Renew my strength and help me soar. Amen.',
      scriptureRef: 'Isaiah 40:31',
      scriptureText: 'But those who hope in the LORD will renew their strength. They will soar on wings like eagles; they will run and not grow weary, they will walk and not be faint.',
      authorName: 'Pastor James',
    },
    {
      title: 'The Good Shepherd',
      content: 'Psalm 23 paints the most beautiful picture of God\'s care for us. He is not a distant deity — He is our personal Shepherd who provides, protects, and leads us.\n\nEven when you walk through dark valleys, He is with you. His presence transforms fear into peace and scarcity into abundance.\n\nPrayer: Lord, You are my Shepherd. I lack nothing when I am in Your care. Lead me today. Amen.',
      scriptureRef: 'Psalm 23:1-4',
      scriptureText: 'The LORD is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters, he refreshes my soul.',
      authorName: 'Minister Sarah',
    },
    {
      title: 'Faith Defined',
      content: 'Faith is not blind optimism — it\'s confident assurance based on the character of God. When we choose faith, we declare that God\'s promises are more real than our circumstances.\n\nToday, exercise your faith. Believe God for the impossible. Take that step He\'s been nudging you toward.\n\nPrayer: Lord, increase my faith. Help me see beyond my circumstances and trust in Your promises. Amen.',
      scriptureRef: 'Hebrews 11:1',
      scriptureText: 'Now faith is confidence in what we hope for and assurance about what we do not see.',
      authorName: 'Pastor James',
    },
  ];

  for (let i = 0; i < devotionalData.length; i++) {
    const d = devotionalData[i];
    const devDate = new Date(today);
    devDate.setDate(devDate.getDate() - (devotionalData.length - 1 - i)); // Spread over last N days including today

    const devotional = await prisma.devotional.upsert({
      where: { date: devDate },
      update: {},
      create: {
        churchId: church.id,
        title: d.title,
        content: d.content,
        scriptureRef: d.scriptureRef,
        scriptureText: d.scriptureText,
        date: devDate,
        authorName: d.authorName,
      },
    });
    devotionals.push(devotional);
  }

  console.log(`  ✅ Devotionals: ${devotionals.length} devotionals created`);

  // ══════════════════════════════════════════════════════
  // PHASE 2: Reading Plans
  // ══════════════════════════════════════════════════════

  const plan1 = await prisma.readingPlan.create({
    data: {
      churchId: church.id,
      title: 'New Believer\'s Journey',
      description: 'A 7-day introduction to the foundations of Christian faith. Perfect for those new to the faith or looking for a fresh start.',
      durationDays: 7,
      category: 'new-believer',
      enrolledCount: 23,
    },
  });

  const plan1Days = [
    { planId: plan1.id, dayNumber: 1, title: 'In the Beginning', scriptureRef: 'Genesis 1:1-31', content: 'Today we start at the very beginning — God created everything. Read Genesis 1 and reflect on the beauty and intentionality of creation. You are fearfully and wonderfully made.' },
    { planId: plan1.id, dayNumber: 2, title: 'God\'s Love for You', scriptureRef: 'John 3:16-18', content: 'God\'s love is not based on your performance. Read John 3:16-18 and meditate on the depth of God\'s love — a love so great He gave His only Son for you.' },
    { planId: plan1.id, dayNumber: 3, title: 'Walking with the Shepherd', scriptureRef: 'Psalm 23:1-6', content: 'The Lord is your shepherd. Read Psalm 23 and consider how God provides, protects, and comforts you in every season of life.' },
    { planId: plan1.id, dayNumber: 4, title: 'The Power of Faith', scriptureRef: 'Hebrews 11:1-6', content: 'Faith is the foundation of our walk with God. Read Hebrews 11:1-6 and understand what it means to live by faith rather than sight.' },
    { planId: plan1.id, dayNumber: 5, title: 'Prayer: Talking to God', scriptureRef: 'Philippians 4:6-7', content: 'Prayer is simply talking to God. Read Philippians 4:6-7 and learn how prayer can transform your anxieties into peace.' },
    { planId: plan1.id, dayNumber: 6, title: 'Nothing Can Separate Us', scriptureRef: 'Romans 8:28-39', content: 'Nothing can separate you from God\'s love. Read Romans 8:28-39 and be encouraged that God works all things together for your good.' },
    { planId: plan1.id, dayNumber: 7, title: 'Strength for the Journey', scriptureRef: 'Isaiah 40:28-31', content: 'As you continue your faith journey, know that God never grows weary. Read Isaiah 40:28-31 and be reminded that He will renew your strength.' },
  ];

  await prisma.readingPlanDay.createMany({ data: plan1Days });

  const plan2 = await prisma.readingPlan.create({
    data: {
      churchId: church.id,
      title: 'Prayer Life Reset',
      description: 'A 5-day plan to revitalize your prayer life and deepen your connection with God.',
      durationDays: 5,
      category: 'prayer',
      enrolledCount: 15,
    },
  });

  const plan2Days = [
    { planId: plan2.id, dayNumber: 1, title: 'Why We Pray', scriptureRef: 'Matthew 6:5-15', content: 'Jesus teaches us how to pray — not with empty words, but with sincerity and faith. Read Matthew 6:5-15 (The Lord\'s Prayer) and reflect on each line.' },
    { planId: plan2.id, dayNumber: 2, title: 'Praying with Boldness', scriptureRef: 'Hebrews 4:14-16', content: 'We can approach God\'s throne with confidence. Read Hebrews 4:14-16 and practice coming boldly before God today.' },
    { planId: plan2.id, dayNumber: 3, title: 'Persistent Prayer', scriptureRef: 'Luke 18:1-8', content: 'The parable of the persistent widow teaches us to never give up in prayer. Read Luke 18:1-8 and be encouraged to keep praying.' },
    { planId: plan2.id, dayNumber: 4, title: 'Prayers of Gratitude', scriptureRef: '1 Thessalonians 5:16-18', content: 'Thanksgiving transforms our perspective. Read 1 Thessalonians 5:16-18 and spend time today thanking God for specific blessings.' },
    { planId: plan2.id, dayNumber: 5, title: 'Praying for Others', scriptureRef: 'James 5:13-16', content: 'Intercessory prayer is powerful. Read James 5:13-16 and commit to praying for others today — family, friends, your church, and your community.' },
  ];

  await prisma.readingPlanDay.createMany({ data: plan2Days });

  console.log(`  ✅ Reading Plans: ${plan1.title} (7 days), ${plan2.title} (5 days)`);

  // ══════════════════════════════════════════════════════
  // PHASE 2: Church Info (Campuses, Staff, Core Values, FAQs)
  // ══════════════════════════════════════════════════════

  // Campuses
  const mainCampus = await prisma.campus.create({
    data: {
      churchId: church.id,
      name: 'Main Campus',
      address: '123 Faith Avenue, Lekki, Lagos, Nigeria',
      lat: 6.4541,
      lng: 3.4745,
      phone: '+234 (1) 234-5678',
      email: 'main@gracecommunity.app',
      isPrimary: true,
    },
  });

  const islandCampus = await prisma.campus.create({
    data: {
      churchId: church.id,
      name: 'Victoria Island Campus',
      address: '456 Adeola Odeku Street, Victoria Island, Lagos, Nigeria',
      lat: 6.4286,
      lng: 3.4218,
      phone: '+234 (1) 345-6789',
      email: 'vi@gracecommunity.app',
      isPrimary: false,
    },
  });

  // Service times
  await prisma.serviceTime.createMany({
    data: [
      { campusId: mainCampus.id, dayOfWeek: 'Sunday', time: '07:30', label: 'First Service' },
      { campusId: mainCampus.id, dayOfWeek: 'Sunday', time: '09:30', label: 'Second Service' },
      { campusId: mainCampus.id, dayOfWeek: 'Wednesday', time: '18:00', label: 'Bible Study' },
      { campusId: islandCampus.id, dayOfWeek: 'Sunday', time: '09:00', label: 'Sunday Service' },
      { campusId: islandCampus.id, dayOfWeek: 'Friday', time: '18:30', label: 'Friday Night Live' },
    ],
  });

  console.log(`  ✅ Campuses: ${mainCampus.name}, ${islandCampus.name} + service times`);

  // Staff Members
  await prisma.staffMember.createMany({
    data: [
      { churchId: church.id, name: 'Pastor James Adeyemi', title: 'Senior Pastor', bio: 'Senior Pastor and founder of Grace Community Church. Over 25 years of ministry experience.', sortOrder: 1 },
      { churchId: church.id, name: 'Pastor Grace Adeyemi', title: 'Associate Pastor', bio: 'Associate Pastor and head of Women\'s Ministry.', sortOrder: 2 },
      { churchId: church.id, name: 'Minister Sarah Okafor', title: 'Worship Director', bio: 'Leading our worship team in creating transformative worship experiences.', sortOrder: 3 },
      { churchId: church.id, name: 'David Eze', title: 'Youth Ministry Director', bio: 'Passionate about reaching the next generation for Christ.', sortOrder: 4 },
      { churchId: church.id, name: 'Blessing Nwosu', title: 'Children\'s Ministry Director', bio: 'Creating a fun, safe environment where children can learn about God\'s love.', sortOrder: 5 },
      { churchId: church.id, name: 'Samuel Obi', title: 'Operations Manager', bio: 'Overseeing the day-to-day operations of all church campuses.', sortOrder: 6 },
    ],
  });

  console.log('  ✅ Staff Members: 6 staff created');

  // Core Values
  await prisma.coreValue.createMany({
    data: [
      { churchId: church.id, title: 'Love', description: 'We believe love is the foundation of everything. We strive to love God and love people unconditionally.', sortOrder: 1 },
      { churchId: church.id, title: 'Faith', description: 'We walk by faith, not by sight. We trust God\'s promises and step out boldly in obedience.', sortOrder: 2 },
      { churchId: church.id, title: 'Community', description: 'We are better together. We build authentic relationships and do life together.', sortOrder: 3 },
      { churchId: church.id, title: 'Excellence', description: 'We honour God by giving our best in everything we do — in worship, service, and ministry.', sortOrder: 4 },
      { churchId: church.id, title: 'Generosity', description: 'We are blessed to be a blessing. We give generously of our time, talents, and resources.', sortOrder: 5 },
    ],
  });

  console.log('  ✅ Core Values: 5 values created');

  // FAQs
  await prisma.fAQ.createMany({
    data: [
      { churchId: church.id, question: 'What time are Sunday services?', answer: 'Our Main Campus has two services: 7:30 AM and 9:30 AM. Our Victoria Island Campus has one service at 9:00 AM.', category: 'services', sortOrder: 1 },
      { churchId: church.id, question: 'How do I join a Connect Group?', answer: 'Connect Groups are small community groups that meet weekly. You can browse available groups in the app under the Groups tab, or speak with any pastor after service.', category: 'groups', sortOrder: 2 },
      { churchId: church.id, question: 'How do I give online?', answer: 'You can give tithes and offerings through the app\'s Giving section. We accept debit cards, bank transfers, and mobile payments.', category: 'giving', sortOrder: 3 },
      { churchId: church.id, question: 'Is there parking available?', answer: 'Yes! Both campuses have free parking. Our ushers will direct you to available spaces when you arrive.', category: 'logistics', sortOrder: 4 },
      { churchId: church.id, question: 'Do you have a children\'s program?', answer: 'Yes! Grace Kids meets during every Sunday service for ages 0-12. We have age-appropriate classes with trained and vetted volunteers.', category: 'services', sortOrder: 5 },
      { churchId: church.id, question: 'How do I become a member?', answer: 'We\'d love to have you! Attend our New Members Class held on the first Sunday of each month after the second service. You can also register through the app.', category: 'membership', sortOrder: 6 },
      { churchId: church.id, question: 'How can I volunteer?', answer: 'We have many volunteer opportunities! Visit the Volunteer section in the app to browse available teams and sign up.', category: 'volunteering', sortOrder: 7 },
    ],
  });

  console.log('  ✅ FAQs: 7 questions created');

  // ══════════════════════════════════════════════════════
  // PHASE 2: Sample User Activity
  // ══════════════════════════════════════════════════════

  // Member saved a sermon
  await prisma.savedSermon.create({
    data: { userId: member.id, sermonId: sermons[0].id },
  }).catch(() => {}); // Ignore if already exists

  // Member has sermon progress
  await prisma.userSermonProgress.create({
    data: {
      userId: member.id,
      sermonId: sermons[0].id,
      position: 1350,
      completed: false,
      lastPlayedAt: new Date(),
    },
  }).catch(() => {});

  // Member has sermon notes
  await prisma.userSermonNote.create({
    data: {
      userId: member.id,
      sermonId: sermons[0].id,
      content: 'Great message about building faith on the right foundation. Key takeaway: faith is not about feelings, it\'s about the Word of God.',
    },
  }).catch(() => {});

  // Member registered for an event
  await prisma.eventRegistration.create({
    data: {
      userId: member.id,
      eventId: events[1].id,
      status: 'REGISTERED',
    },
  }).catch(() => {});

  // Update registered count for that event
  await prisma.event.update({
    where: { id: events[1].id },
    data: { registeredCount: 1 },
  });

  // Member read today's and yesterday's devotional
  if (devotionals.length >= 2) {
    await prisma.userDevotionalRead.create({
      data: { userId: member.id, devotionalId: devotionals[devotionals.length - 1].id },
    }).catch(() => {});
    await prisma.userDevotionalRead.create({
      data: { userId: member.id, devotionalId: devotionals[devotionals.length - 2].id },
    }).catch(() => {});
  }

  // Member enrolled in reading plan
  await prisma.userReadingPlan.create({
    data: {
      userId: member.id,
      planId: plan1.id,
      currentDay: 3,
    },
  }).catch(() => {});

  console.log('  ✅ Sample user activity seeded for member');

  // ══════════════════════════════════════════════════════
  // PHASE 3: Giving & Finances
  // ══════════════════════════════════════════════════════

  console.log('\n📌 Phase 3: Giving & Finances');

  // ── Giving Categories ──────────────────────────────
  const categories = await Promise.all([
    prisma.givingCategory.create({
      data: {
        churchId: church.id,
        name: 'Tithe',
        description: 'Your faithful tithe — 10% of your income given back to God',
        sortOrder: 1,
      },
    }),
    prisma.givingCategory.create({
      data: {
        churchId: church.id,
        name: 'Offering',
        description: 'Free-will offering beyond your tithe',
        sortOrder: 2,
      },
    }),
    prisma.givingCategory.create({
      data: {
        churchId: church.id,
        name: 'Building Fund',
        description: 'Contributions toward our new sanctuary',
        sortOrder: 3,
      },
    }),
    prisma.givingCategory.create({
      data: {
        churchId: church.id,
        name: 'Missions',
        description: 'Supporting missionaries and outreach programs worldwide',
        sortOrder: 4,
      },
    }),
    prisma.givingCategory.create({
      data: {
        churchId: church.id,
        name: 'Special Seed',
        description: 'Special faith offering for specific needs',
        sortOrder: 5,
      },
    }),
  ]);

  console.log(`  ✅ ${categories.length} giving categories created`);

  // ── Giving Campaigns ───────────────────────────────
  const campaign1 = await prisma.givingCampaign.create({
    data: {
      churchId: church.id,
      title: 'New Sanctuary Building Fund',
      description:
        'Help us build a new 2,000-seat sanctuary to accommodate our growing congregation. ' +
        'This state-of-the-art facility will include modern worship spaces, children\'s ministry areas, ' +
        'and community outreach rooms.',
      goalAmount: 5000000,
      raisedAmount: 1750000,
      donorCount: 342,
      startDate: new Date('2025-01-01'),
      endDate: new Date('2026-12-31'),
      isActive: true,
    },
  });

  const campaign2 = await prisma.givingCampaign.create({
    data: {
      churchId: church.id,
      title: 'Youth Camp Scholarship Fund',
      description:
        'Provide scholarships for young people in our community to attend summer camp. ' +
        'Every child deserves a life-changing camp experience!',
      goalAmount: 500000,
      raisedAmount: 275000,
      donorCount: 89,
      startDate: new Date('2025-06-01'),
      endDate: new Date('2026-08-31'),
      isActive: true,
    },
  });

  console.log('  ✅ 2 giving campaigns created');

  // ── Sample Donations ───────────────────────────────
  const now = new Date();
  const donations = [];

  // Member's donations over the last few months
  const donationData = [
    { amount: 50000, categoryIdx: 0, daysAgo: 90, status: 'SUCCESS' as const },
    { amount: 10000, categoryIdx: 1, daysAgo: 83, status: 'SUCCESS' as const },
    { amount: 50000, categoryIdx: 0, daysAgo: 60, status: 'SUCCESS' as const },
    { amount: 25000, categoryIdx: 2, daysAgo: 45, status: 'SUCCESS' as const },
    { amount: 50000, categoryIdx: 0, daysAgo: 30, status: 'SUCCESS' as const },
    { amount: 15000, categoryIdx: 3, daysAgo: 20, status: 'SUCCESS' as const },
    { amount: 50000, categoryIdx: 0, daysAgo: 7, status: 'SUCCESS' as const },
    { amount: 100000, categoryIdx: 2, daysAgo: 5, status: 'SUCCESS' as const, campaignId: campaign1.id },
    { amount: 20000, categoryIdx: 4, daysAgo: 2, status: 'SUCCESS' as const },
    { amount: 50000, categoryIdx: 0, daysAgo: 0, status: 'PENDING' as const },
  ];

  for (let i = 0; i < donationData.length; i++) {
    const d = donationData[i];
    const createdAt = new Date(now);
    createdAt.setDate(createdAt.getDate() - d.daysAgo);

    const receiptNumber = d.status === 'SUCCESS'
      ? `RCP-${createdAt.getFullYear()}${String(createdAt.getMonth() + 1).padStart(2, '0')}${String(createdAt.getDate()).padStart(2, '0')}-${String(i + 1).padStart(4, '0')}`
      : null;

    const donation = await prisma.donation.create({
      data: {
        userId: member.id,
        churchId: church.id,
        categoryId: categories[d.categoryIdx].id,
        campaignId: d.campaignId || null,
        amount: d.amount,
        currency: 'NGN',
        paymentMethod: 'CARD',
        paymentProvider: 'PAYSTACK',
        transactionRef: `PSK-SEED-${Date.now()}-${i}`,
        providerRef: d.status === 'SUCCESS' ? `psk_${Date.now()}_${i}` : null,
        status: d.status,
        receiptNumber,
        isAnonymous: false,
        createdAt,
      },
    });
    donations.push(donation);
  }

  console.log(`  ✅ ${donations.length} sample donations created`);

  // ── Saved Payment Methods ──────────────────────────
  const paymentMethod1 = await prisma.userPaymentMethod.create({
    data: {
      userId: member.id,
      type: 'CARD',
      provider: 'PAYSTACK',
      last4: '4532',
      brand: 'Visa',
      expiryMonth: 12,
      expiryYear: 2028,
      isDefault: true,
      providerToken: 'AUTH_seed_visa_4532',
    },
  });

  const paymentMethod2 = await prisma.userPaymentMethod.create({
    data: {
      userId: member.id,
      type: 'CARD',
      provider: 'PAYSTACK',
      last4: '8791',
      brand: 'Mastercard',
      expiryMonth: 6,
      expiryYear: 2027,
      isDefault: false,
      providerToken: 'AUTH_seed_mc_8791',
    },
  });

  console.log('  ✅ 2 saved payment methods created');

  // ── Pledge ─────────────────────────────────────────
  const pledge1 = await prisma.pledge.create({
    data: {
      userId: member.id,
      churchId: church.id,
      campaignId: campaign1.id,
      title: 'Building Fund Pledge',
      totalAmount: 1200000,
      paidAmount: 400000,
      frequency: 'MONTHLY',
      startDate: new Date('2025-06-01'),
      nextDueDate: new Date(now.getFullYear(), now.getMonth() + 1, 1),
      paymentsCompleted: 4,
      totalPayments: 12,
    },
  });

  // Add pledge payment history
  for (let i = 0; i < 4; i++) {
    const paidAt = new Date('2025-06-01');
    paidAt.setMonth(paidAt.getMonth() + i);
    await prisma.pledgePayment.create({
      data: {
        pledgeId: pledge1.id,
        amount: 100000,
        paidAt,
        status: 'SUCCESS',
      },
    });
  }

  console.log('  ✅ 1 pledge with 4 payments created');

  // ── Recurring Donation ─────────────────────────────
  await prisma.recurringDonation.create({
    data: {
      userId: member.id,
      churchId: church.id,
      categoryId: categories[0].id, // Tithe
      paymentMethodId: paymentMethod1.id,
      amount: 50000,
      currency: 'NGN',
      frequency: 'MONTHLY',
      nextChargeDate: new Date(now.getFullYear(), now.getMonth() + 1, 1),
      status: 'ACTIVE',
      lastChargedAt: new Date(now.getFullYear(), now.getMonth(), 1),
    },
  });

  console.log('  ✅ 1 recurring donation created');

  // ══════════════════════════════════════════════════════
  // PHASE 4: Community & Engagement
  // ══════════════════════════════════════════════════════

  console.log('\n📌 Phase 4: Community & Engagement');

  // ── Connect Groups ─────────────────────────────────
  const groups = await Promise.all([
    prisma.connectGroup.create({
      data: {
        churchId: church.id,
        name: 'Men of Valor',
        description: 'A fellowship group for men focused on spiritual growth, accountability, and brotherhood.',
        category: 'MEN',
        meetingDay: 'Saturday',
        meetingTime: '7:00 AM',
        location: 'Fellowship Hall',
        leaderId: admin.id,
        maxMembers: 30,
        memberCount: 2,
      },
    }),
    prisma.connectGroup.create({
      data: {
        churchId: church.id,
        name: 'Women of Grace',
        description: 'A vibrant community of women growing together in faith, prayer, and sisterhood.',
        category: 'WOMEN',
        meetingDay: 'Wednesday',
        meetingTime: '6:00 PM',
        location: 'Room 201',
        maxMembers: 25,
        memberCount: 0,
      },
    }),
    prisma.connectGroup.create({
      data: {
        churchId: church.id,
        name: 'Youth Ablaze',
        description: 'For young people aged 16-25. Worship, word, and community.',
        category: 'YOUTH',
        meetingDay: 'Friday',
        meetingTime: '5:30 PM',
        location: 'Youth Center',
        maxMembers: 50,
        memberCount: 0,
      },
    }),
    prisma.connectGroup.create({
      data: {
        churchId: church.id,
        name: 'Couples Connect',
        description: 'Building stronger marriages through biblical principles and community.',
        category: 'COUPLES',
        meetingDay: 'Sunday',
        meetingTime: '4:00 PM',
        location: 'Conference Room',
        maxMembers: 20,
        memberCount: 0,
      },
    }),
    prisma.connectGroup.create({
      data: {
        churchId: church.id,
        name: 'Berean Bible Study',
        description: 'In-depth Bible study for those who want to dig deeper into Scripture.',
        category: 'BIBLE_STUDY',
        meetingDay: 'Tuesday',
        meetingTime: '7:00 PM',
        location: 'Library Room',
        leaderId: member.id,
        memberCount: 1,
      },
    }),
    prisma.connectGroup.create({
      data: {
        churchId: church.id,
        name: 'Intercessors United',
        description: 'Corporate prayer and intercession for the church and community.',
        category: 'PRAYER',
        meetingDay: 'Monday',
        meetingTime: '6:00 AM',
        location: 'Sanctuary',
        memberCount: 0,
      },
    }),
  ]);

  // Add memberships for 'Men of Valor' group
  await prisma.groupMembership.createMany({
    data: [
      { userId: admin.id, groupId: groups[0].id, role: 'LEADER' },
      { userId: member.id, groupId: groups[0].id, role: 'MEMBER' },
    ],
  });

  // Berean Bible Study — member is leader
  await prisma.groupMembership.create({
    data: { userId: member.id, groupId: groups[4].id, role: 'LEADER' },
  });

  console.log(`  ✅ ${groups.length} connect groups created`);

  // ── Announcements ──────────────────────────────────
  const announcements = await Promise.all([
    prisma.announcement.create({
      data: {
        churchId: church.id,
        authorId: admin.id,
        title: 'Church Building Fund — Update',
        content: 'We are excited to announce that our building fund has now reached 35% of our target! Thank you for your generous contributions. The construction of the new sanctuary is set to begin next quarter. Please continue to give as the Lord leads.',
        category: 'General',
        isUrgent: false,
        isPinned: true,
        publishedAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2 days ago
      },
    }),
    prisma.announcement.create({
      data: {
        churchId: church.id,
        authorId: admin.id,
        title: 'Special Sunday Service — Guest Speaker',
        content: 'We will be hosting Pastor Emmanuel Afolabi for a special ministry this Sunday. Service starts at 9:00 AM. Please come with family and friends. There will be a special prayer session after the service.',
        category: 'Events',
        isUrgent: true,
        isPinned: false,
        publishedAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // yesterday
      },
    }),
    prisma.announcement.create({
      data: {
        churchId: church.id,
        authorId: admin.id,
        title: 'New Members Orientation — March 2026',
        content: 'If you recently joined our church family, please sign up for the New Members Orientation class. It covers our church beliefs, vision, and how to get connected. Next class: March 15, 2026.',
        category: 'Administration',
        isUrgent: false,
        isPinned: false,
        publishedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
      },
    }),
    prisma.announcement.create({
      data: {
        churchId: church.id,
        authorId: admin.id,
        title: 'Midweek Service Schedule Change',
        content: 'Please note that our Wednesday midweek service has been moved from 6:00 PM to 7:00 PM starting this week. This change is to accommodate more working members.',
        category: 'General',
        isUrgent: false,
        isPinned: false,
        publishedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
      },
    }),
  ]);

  console.log(`  ✅ ${announcements.length} announcements created`);

  // ── Testimonies ────────────────────────────────────
  const testimonies = await Promise.all([
    prisma.testimony.create({
      data: {
        userId: member.id,
        churchId: church.id,
        title: 'God healed me of chronic back pain',
        content: 'For three years I suffered from chronic lower back pain. After the healing service last month, I have been completely pain-free. God is faithful! I want to give Him all the glory.',
        isAnonymous: false,
        status: 'APPROVED',
        approvedAt: new Date(Date.now() - 10 * 24 * 60 * 60 * 1000),
        approvedById: admin.id,
        likeCount: 15,
        prayerCount: 8,
      },
    }),
    prisma.testimony.create({
      data: {
        userId: admin.id,
        churchId: church.id,
        title: 'Miraculous provision for school fees',
        content: 'My children\'s school fees were due and I had no money. I sowed a seed in faith during the offering. Within one week, an unexpected contract came through and I was able to pay everything. God provides!',
        isAnonymous: false,
        status: 'APPROVED',
        approvedAt: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000),
        approvedById: admin.id,
        likeCount: 22,
        prayerCount: 12,
      },
    }),
    prisma.testimony.create({
      data: {
        userId: member.id,
        churchId: church.id,
        title: 'Delivered from addiction',
        content: 'I struggled with substance abuse for years. Through prayer, counseling, and the support of my connect group, I am now 6 months clean. There is power in the name of Jesus.',
        isAnonymous: true,
        status: 'APPROVED',
        approvedAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
        approvedById: admin.id,
        likeCount: 30,
        prayerCount: 20,
      },
    }),
    prisma.testimony.create({
      data: {
        userId: member.id,
        churchId: church.id,
        title: 'Got a new job after months of searching',
        content: 'After 8 months of unemployment, I finally got an offer at a great company. The pastor prayed for me during midweek service and within two weeks I had three interviews and one offer.',
        isAnonymous: false,
        status: 'PENDING', // Not yet approved
        likeCount: 0,
        prayerCount: 0,
      },
    }),
  ]);

  console.log(`  ✅ ${testimonies.length} testimonies created (3 approved, 1 pending)`);

  // ── Forum Categories ───────────────────────────────
  const forumCats = await Promise.all([
    prisma.forumCategory.create({
      data: { churchId: church.id, name: 'General Discussion', description: 'Open discussions about faith, life, and everything in between.', sortOrder: 1 },
    }),
    prisma.forumCategory.create({
      data: { churchId: church.id, name: 'Prayer & Intercession', description: 'Share prayer points and intercede for one another.', sortOrder: 2 },
    }),
    prisma.forumCategory.create({
      data: { churchId: church.id, name: 'Bible Study', description: 'Deep dive into Scripture with fellow believers.', sortOrder: 3 },
    }),
    prisma.forumCategory.create({
      data: { churchId: church.id, name: 'Sermon Discussion', description: 'Discuss recent sermons and share insights.', sortOrder: 4 },
    }),
    prisma.forumCategory.create({
      data: { churchId: church.id, name: 'Relationships', description: 'Biblical wisdom for relationships, marriage, and family.', sortOrder: 5 },
    }),
    prisma.forumCategory.create({
      data: { churchId: church.id, name: 'Youth Corner', description: 'A space for young people to discuss topics relevant to their walk.', sortOrder: 6 },
    }),
    prisma.forumCategory.create({
      data: { churchId: church.id, name: 'Volunteering', description: 'Discussion about service opportunities and volunteer coordination.', sortOrder: 7 },
    }),
    prisma.forumCategory.create({
      data: { churchId: church.id, name: 'Announcements', description: 'Important updates and church news.', sortOrder: 8 },
    }),
  ]);

  console.log(`  ✅ ${forumCats.length} forum categories created`);

  // ── Forum Threads ──────────────────────────────────
  const threads = await Promise.all([
    prisma.forumThread.create({
      data: {
        categoryId: forumCats[0].id, // General Discussion
        churchId: church.id,
        authorId: member.id,
        title: 'How do you maintain a consistent prayer life?',
        content: 'I\'ve been struggling to pray daily. Some days I\'m on fire, other days I barely whisper a prayer. What strategies have worked for you?',
        viewCount: 42,
        likeCount: 8,
        replyCount: 3,
        lastActivityAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000),
      },
    }),
    prisma.forumThread.create({
      data: {
        categoryId: forumCats[2].id, // Bible Study
        churchId: church.id,
        authorId: admin.id,
        title: 'Understanding the Book of Revelation — Chapter 1',
        content: 'Let\'s study through the book of Revelation together. Starting with Chapter 1: The Revelation of Jesus Christ. John was on the island of Patmos when he received this vision. What stands out to you in this opening chapter?',
        isPinned: true,
        viewCount: 85,
        likeCount: 15,
        replyCount: 5,
        lastActivityAt: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000),
      },
    }),
    prisma.forumThread.create({
      data: {
        categoryId: forumCats[3].id, // Sermon Discussion
        churchId: church.id,
        authorId: member.id,
        title: 'Thoughts on last Sunday\'s sermon about faith',
        content: 'Pastor\'s message on faith really hit home for me. The point about faith being action, not just belief, was powerful. What stood out to you?',
        viewCount: 30,
        likeCount: 5,
        replyCount: 2,
        lastActivityAt: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000),
      },
    }),
    prisma.forumThread.create({
      data: {
        categoryId: forumCats[4].id, // Relationships
        churchId: church.id,
        authorId: admin.id,
        title: 'Christian dating in the modern world',
        content: 'How do we navigate dating as believers in today\'s world? What biblical principles should guide our relationships?',
        viewCount: 65,
        likeCount: 12,
        replyCount: 4,
        lastActivityAt: new Date(Date.now() - 4 * 24 * 60 * 60 * 1000),
      },
    }),
  ]);

  // Update category thread counts
  await prisma.forumCategory.update({ where: { id: forumCats[0].id }, data: { threadCount: 1 } });
  await prisma.forumCategory.update({ where: { id: forumCats[2].id }, data: { threadCount: 1 } });
  await prisma.forumCategory.update({ where: { id: forumCats[3].id }, data: { threadCount: 1 } });
  await prisma.forumCategory.update({ where: { id: forumCats[4].id }, data: { threadCount: 1 } });

  // ── Forum Replies ──────────────────────────────────
  await prisma.forumReply.createMany({
    data: [
      { threadId: threads[0].id, authorId: admin.id, content: 'Setting a specific time helps me. I pray first thing in the morning before checking my phone.', likeCount: 3 },
      { threadId: threads[0].id, authorId: member.id, content: 'I use a prayer journal. Writing down my prayers keeps me focused and also helps me track how God answers them.', likeCount: 2 },
      { threadId: threads[0].id, authorId: admin.id, content: 'Prayer walks are great too! Combining exercise and prayer works wonders for consistency.', likeCount: 1 },
      { threadId: threads[1].id, authorId: member.id, content: 'The description of Jesus in verses 13-16 is incredibly powerful. The imagery of His eyes like a flame of fire really stood out.', likeCount: 4 },
      { threadId: threads[1].id, authorId: admin.id, content: 'What struck me was verse 8: "I am the Alpha and the Omega." This sets the tone for the entire book.', likeCount: 5 },
    ],
  });

  console.log(`  ✅ ${threads.length} forum threads + 5 replies created`);

  // ── Prayer Requests ────────────────────────────────
  const prayerRequests = await Promise.all([
    prisma.prayerRequest.create({
      data: {
        userId: member.id,
        churchId: church.id,
        title: 'Pray for my mother\'s surgery',
        content: 'My mother is scheduled for surgery next week. Please pray for the surgeons, for a successful operation, and for a quick recovery. God is able!',
        isAnonymous: false,
        isUrgent: true,
        status: 'ACTIVE',
        prayerCount: 12,
      },
    }),
    prisma.prayerRequest.create({
      data: {
        userId: admin.id,
        churchId: church.id,
        title: 'Wisdom for a career decision',
        content: 'I have two job offers and I need God\'s direction. Please pray that I make the right choice that aligns with His will for my life.',
        isAnonymous: false,
        isUrgent: false,
        status: 'ACTIVE',
        prayerCount: 8,
      },
    }),
    prisma.prayerRequest.create({
      data: {
        userId: member.id,
        churchId: church.id,
        title: 'Financial breakthrough needed',
        content: 'Going through a difficult financial season. Please stand with me in prayer for God\'s provision and open doors.',
        isAnonymous: true,
        isUrgent: true,
        status: 'ACTIVE',
        prayerCount: 15,
      },
    }),
    prisma.prayerRequest.create({
      data: {
        userId: member.id,
        churchId: church.id,
        title: 'My friend\'s salvation',
        content: 'I have a close friend who doesn\'t know the Lord. Please join me in praying for their heart to be opened to the Gospel.',
        isAnonymous: false,
        isUrgent: false,
        status: 'ACTIVE',
        prayerCount: 6,
      },
    }),
    prisma.prayerRequest.create({
      data: {
        userId: admin.id,
        churchId: church.id,
        title: 'Healing from anxiety — ANSWERED!',
        content: 'Thank you all for praying. God has truly delivered me from anxiety. I am at peace and sleeping well. Glory to God!',
        isAnonymous: false,
        isUrgent: false,
        status: 'ANSWERED',
        prayerCount: 20,
      },
    }),
  ]);

  // Add some prayer interactions
  await prisma.prayerInteraction.createMany({
    data: [
      { userId: admin.id, prayerRequestId: prayerRequests[0].id },
      { userId: admin.id, prayerRequestId: prayerRequests[2].id },
      { userId: member.id, prayerRequestId: prayerRequests[1].id },
      { userId: member.id, prayerRequestId: prayerRequests[4].id },
    ],
  });

  console.log(`  ✅ ${prayerRequests.length} prayer requests created (4 active, 1 answered)`);

  // ── Invite Links ───────────────────────────────────
  const invite = await prisma.inviteLink.create({
    data: {
      userId: member.id,
      churchId: church.id,
      code: 'GRACE2026A',
      usedCount: 3,
      expiresAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days from now
    },
  });

  console.log('  ✅ 1 invite link created');

  // ══════════════════════════════════════════════════════
  // PHASE 5: Real-Time & Notifications
  // ══════════════════════════════════════════════════════

  // ── Conversations ──────────────────────────────────
  const directConvo = await prisma.conversation.create({
    data: {
      type: 'DIRECT',
      createdById: admin.id,
      churchId: church.id,
      members: {
        create: [
          { userId: admin.id, role: 'ADMIN' },
          { userId: member.id, role: 'MEMBER' },
        ],
      },
    },
  });

  const groupConvo = await prisma.conversation.create({
    data: {
      type: 'GROUP',
      name: 'Church Leadership Team',
      createdById: admin.id,
      churchId: church.id,
      members: {
        create: [
          { userId: admin.id, role: 'ADMIN' },
          { userId: member.id, role: 'MEMBER' },
        ],
      },
    },
  });

  // ── Messages ───────────────────────────────────────
  const messages = await Promise.all([
    prisma.message.create({
      data: {
        conversationId: directConvo.id,
        senderId: admin.id,
        content: 'Welcome to Grace Community Church! Feel free to reach out anytime.',
        type: 'TEXT',
      },
    }),
    prisma.message.create({
      data: {
        conversationId: directConvo.id,
        senderId: member.id,
        content: 'Thank you, Pastor James! Glad to be part of this community.',
        type: 'TEXT',
      },
    }),
    prisma.message.create({
      data: {
        conversationId: groupConvo.id,
        senderId: admin.id,
        content: 'Team, let\'s discuss plans for the upcoming Easter service.',
        type: 'TEXT',
      },
    }),
    prisma.message.create({
      data: {
        conversationId: groupConvo.id,
        senderId: member.id,
        content: 'I can handle the media setup. Will prepare the graphics this week.',
        type: 'TEXT',
      },
    }),
  ]);

  // Update last message on conversations
  await Promise.all([
    prisma.conversation.update({
      where: { id: directConvo.id },
      data: { lastMessageAt: messages[1].createdAt },
    }),
    prisma.conversation.update({
      where: { id: groupConvo.id },
      data: { lastMessageAt: messages[3].createdAt },
    }),
  ]);

  console.log(`  ✅ Conversations: 2 (1 direct, 1 group) with ${messages.length} messages`);

  // ── Notifications ──────────────────────────────────
  const notifications = await Promise.all([
    prisma.notification.create({
      data: {
        userId: member.id,
        type: 'EVENT',
        title: 'Night of Worship & Prayer',
        body: 'Don\'t forget! The Night of Worship & Prayer is this Friday at 6 PM.',
        data: { eventId: events[1].id },
      },
    }),
    prisma.notification.create({
      data: {
        userId: member.id,
        type: 'SERMON',
        title: 'New Sermon Available',
        body: 'Pastor James just uploaded "Prayer Changes Everything". Listen now!',
        data: { sermonId: sermons[4].id },
      },
    }),
    prisma.notification.create({
      data: {
        userId: member.id,
        type: 'CHAT',
        title: 'New Message from Pastor James',
        body: 'Welcome to Grace Community Church! Feel free to reach out anytime.',
        data: { conversationId: directConvo.id },
        isRead: true,
        readAt: new Date(),
      },
    }),
    prisma.notification.create({
      data: {
        userId: admin.id,
        type: 'PRAYER',
        title: 'Someone Prayed for You',
        body: 'John Doe prayed for your prayer request "Church Building Fund".',
        data: {},
      },
    }),
    prisma.notification.create({
      data: {
        userId: member.id,
        type: 'GIVING',
        title: 'Donation Received',
        body: 'Your donation of $100.00 to General Fund has been received. Thank you!',
        data: {},
      },
    }),
    prisma.notification.create({
      data: {
        userId: admin.id,
        type: 'ANNOUNCEMENT',
        title: 'New Community Announcement',
        body: 'Easter Sunday special service — come early for breakfast fellowship!',
        data: {},
      },
    }),
  ]);

  console.log(`  ✅ Notifications: ${notifications.length} created`);

  // ── Live Services ──────────────────────────────────
  const liveServices = await Promise.all([
    prisma.liveService.create({
      data: {
        churchId: church.id,
        title: 'Sunday Worship Live',
        description: 'Join our live Sunday worship service. Worship, Word, and Fellowship.',
        status: 'SCHEDULED',
        scheduledAt: new Date(Date.now() + 3 * 24 * 60 * 60 * 1000), // 3 days from now
        streamUrl: 'https://stream.gracecommunity.app/live',
        viewerCount: 0,
      },
    }),
    prisma.liveService.create({
      data: {
        churchId: church.id,
        title: 'Midweek Bible Study',
        description: 'Interactive Bible study — bring your questions!',
        status: 'SCHEDULED',
        scheduledAt: new Date(Date.now() + 5 * 24 * 60 * 60 * 1000), // 5 days from now
        streamUrl: 'https://stream.gracecommunity.app/biblestudy',
        viewerCount: 0,
      },
    }),
    prisma.liveService.create({
      data: {
        churchId: church.id,
        title: 'Last Week\'s Sunday Service',
        description: 'Recording of last Sunday\'s powerful worship service.',
        status: 'ENDED',
        scheduledAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        startedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000),
        endedAt: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000 + 2 * 60 * 60 * 1000),
        streamUrl: 'https://stream.gracecommunity.app/archive/last-sunday',
        viewerCount: 245,
      },
    }),
  ]);

  // Add some chat messages to the ended live service
  await prisma.liveChatMessage.createMany({
    data: [
      { liveServiceId: liveServices[2].id, userId: admin.id, content: 'Welcome everyone to today\'s service! 🙏', type: 'MESSAGE' },
      { liveServiceId: liveServices[2].id, userId: member.id, content: 'Good morning! Excited to worship together!', type: 'MESSAGE' },
      { liveServiceId: liveServices[2].id, userId: member.id, content: '🙌', type: 'REACTION' },
      { liveServiceId: liveServices[2].id, userId: admin.id, content: 'Please pray for Sister Grace who is in the hospital.', type: 'PRAYER' },
      { liveServiceId: liveServices[2].id, userId: member.id, content: 'Praying! 🙏', type: 'MESSAGE' },
    ],
  });

  console.log(`  ✅ Live Services: ${liveServices.length} (2 scheduled, 1 ended) with chat messages`);

  // ══════════════════════════════════════════════════════
  // PHASE 6: Volunteering, Kids, Media, Search
  // ══════════════════════════════════════════════════════

  console.log('\n📌 Phase 6: Volunteering, Kids, Media & Search');

  // ── Volunteer Opportunities ─────────────────────────
  const opportunities = await Promise.all([
    prisma.volunteerOpportunity.create({
      data: {
        churchId: church.id,
        title: 'Worship Team Vocalist',
        description: 'Lead worship and sing during Sunday services. Must have vocal training or choir experience.',
        department: 'Worship',
        requirements: 'Vocal audition required. Must attend Thursday rehearsals.',
        isActive: true,
      },
    }),
    prisma.volunteerOpportunity.create({
      data: {
        churchId: church.id,
        title: 'Children\'s Ministry Helper',
        description: 'Help care for and teach children ages 3-5 during Sunday services.',
        department: 'Children',
        requirements: 'Background check required. Must be 18+.',
        isActive: true,
      },
    }),
    prisma.volunteerOpportunity.create({
      data: {
        churchId: church.id,
        title: 'Audio/Visual Technician',
        description: 'Operate sound board, projectors, and live stream equipment during services.',
        department: 'Technical',
        requirements: 'Training provided. Basic tech knowledge helpful.',
        isActive: true,
      },
    }),
    prisma.volunteerOpportunity.create({
      data: {
        churchId: church.id,
        title: 'Parking & Ushering Team',
        description: 'Welcome guests, assist with seating, and manage parking lot on Sunday mornings.',
        department: 'Ushering',
        isActive: true,
      },
    }),
    prisma.volunteerOpportunity.create({
      data: {
        churchId: church.id,
        title: 'Media & Photography',
        description: 'Capture photos and videos of church events and services for social media.',
        department: 'Media',
        requirements: 'Must have own camera or smartphone. Editing skills a plus.',
        isActive: false, // Currently not recruiting
      },
    }),
  ]);

  // Signup member for a couple of opportunities
  await prisma.volunteerSignup.create({
    data: { userId: member.id, opportunityId: opportunities[0].id, status: 'APPROVED' },
  });
  await prisma.volunteerSignup.create({
    data: { userId: member.id, opportunityId: opportunities[2].id, status: 'PENDING' },
  });

  // Create roster shifts for the member
  const nextSunday = new Date();
  nextSunday.setDate(nextSunday.getDate() + (7 - nextSunday.getDay()));
  const followingSunday = new Date(nextSunday);
  followingSunday.setDate(followingSunday.getDate() + 7);

  await prisma.rosterShift.createMany({
    data: [
      {
        churchId: church.id,
        userId: member.id,
        opportunityId: opportunities[0].id,
        date: nextSunday,
        startTime: '07:00',
        endTime: '10:00',
        status: 'SCHEDULED',
      },
      {
        churchId: church.id,
        userId: member.id,
        opportunityId: opportunities[0].id,
        date: followingSunday,
        startTime: '07:00',
        endTime: '10:00',
        status: 'SCHEDULED',
      },
      {
        churchId: church.id,
        userId: admin.id,
        opportunityId: opportunities[2].id,
        date: nextSunday,
        startTime: '06:30',
        endTime: '12:00',
        status: 'SCHEDULED',
      },
    ],
  });

  console.log(`  ✅ Volunteer Opportunities: ${opportunities.length}, Signups: 2, Shifts: 3`);

  // ── Kids Check-In: Children & Rooms ─────────────────
  const rooms = await Promise.all([
    prisma.room.create({
      data: { churchId: church.id, name: 'Nursery', ageGroup: '0-2', capacity: 15 },
    }),
    prisma.room.create({
      data: { churchId: church.id, name: 'Toddlers Room', ageGroup: '3-5', capacity: 20 },
    }),
    prisma.room.create({
      data: { churchId: church.id, name: 'Junior Church', ageGroup: '6-8', capacity: 25 },
    }),
    prisma.room.create({
      data: { churchId: church.id, name: 'Pre-Teen Room', ageGroup: '9-12', capacity: 20 },
    }),
  ]);

  const children = await Promise.all([
    prisma.child.create({
      data: {
        parentId: member.id,
        churchId: church.id,
        firstName: 'David',
        lastName: 'Doe',
        dateOfBirth: new Date('2019-04-15'),
        allergies: 'Peanuts',
      },
    }),
    prisma.child.create({
      data: {
        parentId: member.id,
        churchId: church.id,
        firstName: 'Sarah',
        lastName: 'Doe',
        dateOfBirth: new Date('2021-08-22'),
      },
    }),
  ]);

  console.log(`  ✅ Kids: ${rooms.length} rooms, ${children.length} children registered`);

  // ── Photo Albums & Photos ───────────────────────────
  const albums = await Promise.all([
    prisma.photoAlbum.create({
      data: {
        churchId: church.id,
        title: 'Sunday Service Highlights',
        description: 'Photos from our Sunday worship services.',
        photoCount: 3,
      },
    }),
    prisma.photoAlbum.create({
      data: {
        churchId: church.id,
        title: 'Youth Camp 2025',
        description: 'Memories from our annual youth camp.',
        photoCount: 2,
      },
    }),
  ]);

  await prisma.photo.createMany({
    data: [
      { albumId: albums[0].id, churchId: church.id, uploadedById: admin.id, imageUrl: 'https://picsum.photos/seed/worship1/800/600', caption: 'Worship team leading praise' },
      { albumId: albums[0].id, churchId: church.id, uploadedById: admin.id, imageUrl: 'https://picsum.photos/seed/worship2/800/600', caption: 'Pastor\'s sermon' },
      { albumId: albums[0].id, churchId: church.id, uploadedById: member.id, imageUrl: 'https://picsum.photos/seed/worship3/800/600', caption: 'Fellowship after service' },
      { albumId: albums[1].id, churchId: church.id, uploadedById: admin.id, imageUrl: 'https://picsum.photos/seed/camp1/800/600', caption: 'Campfire worship' },
      { albumId: albums[1].id, churchId: church.id, uploadedById: member.id, imageUrl: 'https://picsum.photos/seed/camp2/800/600', caption: 'Group activities' },
    ],
  });

  console.log(`  ✅ Photo Albums: ${albums.length} with 5 photos`);

  // ── Podcast Episodes ────────────────────────────────
  const podcasts = await prisma.podcastEpisode.createManyAndReturn({
    data: [
      {
        churchId: church.id,
        title: 'Walking in Faith - Episode 1',
        description: 'Pastor James explores what it truly means to walk by faith, not by sight.',
        audioUrl: 'https://example.com/podcasts/walking-faith-01.mp3',
        duration: 1800,
        thumbnailUrl: 'https://picsum.photos/seed/pod1/400/400',
        publishedAt: new Date('2025-01-15'),
        playCount: 156,
      },
      {
        churchId: church.id,
        title: 'Walking in Faith - Episode 2',
        description: 'Continuing our series on faith — this week: trusting God in the waiting season.',
        audioUrl: 'https://example.com/podcasts/walking-faith-02.mp3',
        duration: 2100,
        thumbnailUrl: 'https://picsum.photos/seed/pod2/400/400',
        publishedAt: new Date('2025-01-22'),
        playCount: 89,
      },
      {
        churchId: church.id,
        title: 'Parenting with Purpose',
        description: 'A special episode on raising children in a faith-centered home.',
        audioUrl: 'https://example.com/podcasts/parenting-purpose.mp3',
        duration: 2400,
        thumbnailUrl: 'https://picsum.photos/seed/pod3/400/400',
        publishedAt: new Date('2025-02-01'),
        playCount: 234,
      },
    ],
  });

  // Add progress for member on first podcast
  await prisma.userPodcastProgress.create({
    data: { userId: member.id, episodeId: podcasts[0].id, position: 900, completed: false },
  });

  console.log(`  ✅ Podcasts: ${podcasts.length} episodes with 1 user progress`);

  // ── Worship Songs ───────────────────────────────────
  const songs = await Promise.all([
    prisma.worshipSong.create({
      data: {
        churchId: church.id,
        title: 'Amazing Grace',
        artist: 'John Newton',
        key: 'G',
        tempo: 72,
        tags: ['hymn', 'classic', 'communion'],
        sections: {
          create: [
            {
              type: 'VERSE',
              sortOrder: 1,
              lines: {
                create: [
                  { lineNumber: 1, lyrics: 'Amazing grace, how sweet the sound', chords: 'G           C/G    G' },
                  { lineNumber: 2, lyrics: 'That saved a wretch like me', chords: '      G              D' },
                  { lineNumber: 3, lyrics: 'I once was lost, but now am found', chords: 'G           C/G    G' },
                  { lineNumber: 4, lyrics: 'Was blind but now I see', chords: '  G        D    G' },
                ],
              },
            },
            {
              type: 'VERSE',
              sortOrder: 2,
              lines: {
                create: [
                  { lineNumber: 1, lyrics: "'Twas grace that taught my heart to fear", chords: 'G           C/G    G' },
                  { lineNumber: 2, lyrics: 'And grace my fears relieved', chords: '      G              D' },
                  { lineNumber: 3, lyrics: 'How precious did that grace appear', chords: 'G           C/G    G' },
                  { lineNumber: 4, lyrics: 'The hour I first believed', chords: '  G        D    G' },
                ],
              },
            },
          ],
        },
      },
    }),
    prisma.worshipSong.create({
      data: {
        churchId: church.id,
        title: 'Good Good Father',
        artist: 'Chris Tomlin',
        key: 'A',
        tempo: 68,
        tags: ['contemporary', 'worship', 'popular'],
        sections: {
          create: [
            {
              type: 'VERSE',
              sortOrder: 1,
              lines: {
                create: [
                  { lineNumber: 1, lyrics: "I've heard a thousand stories of what they think you're like", chords: 'A                    E' },
                  { lineNumber: 2, lyrics: "But I've heard the tender whisper of love in the dead of night", chords: 'F#m                D' },
                ],
              },
            },
            {
              type: 'CHORUS',
              sortOrder: 2,
              lines: {
                create: [
                  { lineNumber: 1, lyrics: "You're a good good father, it's who you are", chords: 'A        E        F#m    D' },
                  { lineNumber: 2, lyrics: "And I'm loved by you, it's who I am", chords: 'A        E        F#m    D' },
                ],
              },
            },
          ],
        },
      },
    }),
    prisma.worshipSong.create({
      data: {
        churchId: church.id,
        title: 'How Great Is Our God',
        artist: 'Chris Tomlin',
        key: 'C',
        tempo: 78,
        tags: ['worship', 'praise', 'popular'],
        sections: {
          create: [
            {
              type: 'VERSE',
              sortOrder: 1,
              lines: {
                create: [
                  { lineNumber: 1, lyrics: 'The splendor of a King, clothed in majesty', chords: 'C                         Am' },
                  { lineNumber: 2, lyrics: 'Let all the earth rejoice, all the earth rejoice', chords: 'F                      C' },
                ],
              },
            },
            {
              type: 'CHORUS',
              sortOrder: 2,
              lines: {
                create: [
                  { lineNumber: 1, lyrics: 'How great is our God, sing with me', chords: 'C               Am' },
                  { lineNumber: 2, lyrics: 'How great is our God, and all will see', chords: 'F            G      C' },
                  { lineNumber: 3, lyrics: 'How great, how great is our God', chords: 'Am        F       C' },
                ],
              },
            },
          ],
        },
      },
    }),
  ]);

  console.log(`  ✅ Worship Songs: ${songs.length} with sections & lyrics`);

  console.log('\n🎉 Seed completed!\n');
}

seed()
  .catch((e) => {
    console.error('Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
