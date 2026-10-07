// Throwaway SVG safe-area preview. No backend, login, or persistence.
import { spawnSync } from 'node:child_process'
import { createServer } from 'node:http'
import { readFileSync } from 'node:fs'
import { dirname, resolve } from 'node:path'
import { fileURLToPath } from 'node:url'

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..')
const output = resolve(root, 'elm-stuff/guild-curves-svg-prototype.js')
const build = spawnSync(resolve(root, 'node_modules/.bin/lamdera'), ['make', 'src/GuildCurvesSvgPrototype.elm', '--output=' + output], { cwd: root, stdio: 'inherit' })
if (build.status !== 0) process.exit(build.status ?? 1)

const html = `<!doctype html><html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>SVG safe-area prototype</title><style>body{margin:0;background:#040614}</style></head><body><div id="app"></div><script src="/prototype.js"></script><script>
const params=new URLSearchParams(location.search);
const app=Elm.GuildCurvesSvgPrototype.init({node:document.getElementById('app'),flags:{inset:Number(params.get('inset')||40),zoom:Number(params.get('zoom')||1),selected:Number(params.get('selected')||1)}});
app.ports.prototypeState.subscribe(state=>{for(const key of ['inset','zoom','selected'])params.set(key,state[key]);history.replaceState(null,'','?'+params)});
</script></body></html>`

const images = {
  avatar: ['tests/data/at-user-icon.png', 'image/png'],
  sheep: ['public/cacheable/sheep-game-preview.webp', 'image/webp'],
  'at-chat': ['public/cacheable/at-logo-no-background.png', 'image/png'],
}
createServer((req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname
  let data, type
  if (path === '/') {
    data = html; type = 'text/html'
  } else if (path === '/prototype.js') {
    data = readFileSync(output, 'utf8').replaceAll('http://localhost:3000', ''); type = 'application/javascript'
  } else if (path.startsWith('/file/2/') && images[path.slice(8)]) {
    const [image, mime] = images[path.slice(8)]
    data = readFileSync(resolve(root, image)); type = mime
  } else if (path.startsWith('/cacheable/fonts/') && !path.includes('..')) {
    data = readFileSync(resolve(root, 'public' + path)); type = 'font/woff2'
  } else {
    res.writeHead(404).end(); return
  }
  res.writeHead(200, { 'Content-Type': type, 'Cache-Control': 'no-cache' }).end(data)
}).listen(Number(process.env.PORT || 8110), '0.0.0.0', () => console.log('SVG safe-area prototype ready'))
