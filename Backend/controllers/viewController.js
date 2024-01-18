// controllers/viewController.js

const fs = require('fs');

const renderIndex = (req, res) => {
  const indexPath = `${__dirname}/../views/index.html`;
  const indexHTML = fs.readFileSync(indexPath, 'utf-8');
  res.send(indexHTML);
};

module.exports = {
  renderIndex,
};
