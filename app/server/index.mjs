import cors from 'cors'
import { execa } from 'execa'
import express from 'express'
import bodyParser from 'body-parser'
import ratelimit from 'express-rate-limit'
import axios from 'axios'

const port = 8081

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
  try {
    if (!req.query.code) {
      res.send('Invalid code')
      return
    }

    // const code = decodeURIComponent(
    //   Buffer.from(req.query.code, 'base64').toString('ascii')
    // )

    // console.log({ code })

    const { stdout } = await execa('docker', [
      'run',
      '-t',
      'fae0/beef',
      req.query.code,
    ])

    res.send(stdout)
  } catch (e) {
    // console.log(e)
    res.send(e.stdout)
  }
})

app.post('/sprunge/:code', async (req, res) => {
  try {
    const data = new URLSearchParams(`sprunge=${req.params.code}`)
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
