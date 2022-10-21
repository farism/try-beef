import axios from 'axios'
import bodyParser from 'body-parser'
import cors from 'cors'
import { execa } from 'execa'
import express from 'express'
import ratelimit from 'express-rate-limit'
import { v4 } from 'uuid'

const port = process.env.PORT || 8080

const timeout = 10000

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

app.get('/compile?', async (req, res) => {
  if (!req.query.code) {
    return res.send('Invalid code')
  }

  const name = v4()

  const code = btoa(decodeURIComponent(atob(req.query.code)))

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
  }, timeout)

  execa('docker', [
    'run',
    '-t',
    '--memory',
    '150mb',
    '--name',
    name,
    'fae0/beef',
    code,
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

app.post('/sprunge?', async (req, res) => {
  try {
    const data = new URLSearchParams(`sprunge=${req.query.code}`)
    const sprunge = await axios.post('http://sprunge.us', data)
    res.send(sprunge.data)
  } catch (e) {
    res.send('')
  }
})

app.get('/sprunge/:id', async (req, res) => {
  try {
    const sprunge = await axios.get(`http://sprunge.us/${req.params.id}`)
    res.send(sprunge.data)
  } catch (e) {
    res.send('')
  }
})

app.listen(port, () => {
  console.log(`listening on port ${port}`)
})
