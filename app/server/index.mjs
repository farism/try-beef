import axios from 'axios'
import bodyParser from 'body-parser'
import cors from 'cors'
import { execa } from 'execa'
import express from 'express'
import ratelimit from 'express-rate-limit'
import { v4 } from 'uuid'

const PORT = process.env.PORT || 8080
const TIMEOUT = 10000
const MICROBIN_URL = 'https://microbin-misty-violet-1746.fly.dev'

const app = express()

app.use(
  cors(),
  ratelimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per `window` (here, per 15 minutes)
  }),
  bodyParser.json(),
  bodyParser.urlencoded({ extended: true })
)

app.get('/upload/:id', async (req, res) => {
  try {
    const response = await fetch(`${MICROBIN_URL}/raw/${req.params.id}`)

    res.send(await response.text())
  } catch (e) {
    res.status(500).send('error')
  }
})

app.post('/upload', async (req, res) => {
  const data = {
    expiration: 'never',
    burn_after: 0,
    syntax_highlight: 'none',
    privacy: 'public',
    content: req.body.code,
  }

  const body = new FormData()

  Object.entries(data).forEach(([k, v]) => body.append(k, String(v)))

  try {
    const response = await fetch(`${MICROBIN_URL}/upload`, {
      method: 'POST',
      body,
    })

    const responseUrl = response.url.split('/')

    const id = responseUrl[responseUrl.length - 1]

    res.send(id)
  } catch (e) {
    res.status(500).send('error', e.message)
  }
})

app.post('/compile', async (req, res) => {
  const name = v4()

  // kill container after 10 sec
  setTimeout(async () => {
    try {
      const running = await execa('docker', ['ps', '--format', '{{.Names}}'])

      if (running.stdout.includes(name)) {
        execa('docker', ['kill', name])

        res.send('Timed out')
      }
    } catch (e) {
      console.error(e)
    }
  }, TIMEOUT)

  execa('docker', [
    'run',
    '-t',
    '--memory',
    '150mb',
    '--name',
    name,
    'fae0/beef',
    req.body.id,
  ])
    .then((result) => {
      if (!res.headersSent) {
        res.send(result.stdout)
      }
    })
    .catch((error) => {
      if (!res.headersSent) {
        res.send(error.stdout)
      }
    })
})

app.listen(PORT, () => {
  console.log(`listening on port ${PORT}`)
})
