const CACHE = 'mostik-v5.3.27-cache';
const STATIC = [
  '/',
  '/app.css',
  '/app.js',
  '/icons/icon-512.png',
  '/icons/icon-192.png',
  '/icons/icon-maskable-512.png',
  '/icons/icon-maskable-192.png',
  '/offline.html',
  '/manifest.webmanifest',
  '/assets/logos/classic.webp',
  '/assets/logos/bull.webp',
  '/assets/logos/horizon.webp',
  '/assets/logos/serpent.webp',
  '/assets/logos/lion.webp',
  '/assets/logos/eagle.webp',
  '/assets/logos/elephant.webp',
  '/assets/logos/fox.webp',
  '/assets/logos/nest.webp',
  '/assets/logos/owl.webp',
  '/assets/logos/cyber.webp',
  '/assets/logos/cosmos.webp',
  '/assets/animal-icons/icon-1.webp',
  '/assets/animal-icons/icon-2.webp',
  '/assets/animal-icons/icon-3.webp',
  '/assets/animal-icons/icon-4.webp',
  '/assets/animal-icons/icon-5.webp',
  '/assets/animal-icons/icon-6.webp',
  '/assets/animal-icons/icon-7.webp',
  '/assets/animal-icons/icon-8.webp',
  '/assets/animal-icons/icon-9.webp',
  '/assets/animal-icons/icon-10.webp',
  '/assets/animal-icons/icon-11.webp',
  '/assets/animal-icons/icon-12.webp'
];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE).then(cache => cache.addAll(STATIC)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return;

  const staticAsset = ['/', '/app.css', '/app.js', '/manifest.webmanifest',
  '/assets/logos/classic.webp',
  '/assets/logos/bull.webp',
  '/assets/logos/horizon.webp',
  '/assets/logos/serpent.webp',
  '/assets/logos/lion.webp',
  '/assets/logos/eagle.webp',
  '/assets/logos/elephant.webp',
  '/assets/logos/fox.webp',
  '/assets/logos/nest.webp',
  '/assets/logos/owl.webp',
  '/assets/logos/cyber.webp',
  '/assets/logos/cosmos.webp',
    '/icons/icon-512.png', '/icons/icon-192.png',
    '/icons/icon-maskable-512.png', '/icons/icon-maskable-192.png'].includes(url.pathname)
    || url.pathname.startsWith('/assets/animal-icons/');

  if (event.request.mode === 'navigate') {
    event.respondWith(
      caches.match(event.request).then(cached =>
        cached || fetch(event.request).catch(() => caches.match('/offline.html'))
      )
    );
    return;
  }

  if (staticAsset) {
    event.respondWith((async () => {
      const cached = await caches.match(event.request);
      const network = fetch(event.request).then(response => {
        if (response.ok) {
          const copy = response.clone();
          caches.open(CACHE).then(cache => cache.put(event.request, copy));
        }
        return response;
      }).catch(() => cached);
      return cached || network;
    })());
    return;
  }

  event.respondWith(caches.match(event.request).then(cached => cached || fetch(event.request)));
});
