require('dotenv').config();
const app = require('./app');

const porta = Number(process.env.PORT || 3000);
app.listen(porta, '0.0.0.0', () => {
  console.log(`ES Stock API a correr em http://localhost:${porta}`);
});
