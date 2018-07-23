exports.handler = function(event, context) {
    const timeDiff = event.timeDiff;
    const ID = event.ID;
    let result;
    switch(ID) {
        case "always200Pounds":
            result = 200;
            break;
        case "losesAllWeightImmediately":
            if (timeDiff === 0) {
                result = 200;
            } else {
                result = 0;
            }
            break;
        case "losesOnePoundPerSecond":
            if (timeDiff < 200) {
                result = 200 - timeDiff;
            } else {
                result = 0;
            }
            break;
        default:
            result = 200;
            break;
    }
    context.done(null, result);
};


^AWS
vExpress


app.get('/:ID/:timeDiff', (req, res) => {
  const ID = req.params.ID;
  const timeDiff = parseInt(req.params.timeDiff, 10);
  let result;
  switch(ID) {
    case "always200Pounds":
      result = 200;
      break;
    case "losesAllWeightImmediately":
      if (timeDiff === 0) {
        result = 200;
      } else {
        result = 0;
      }
      break;
    case "losesOnePoundPerSecond":
      if (timeDiff < 200) {
        result = 200 - timeDiff;
      } else {
        result = 0;
      }
      break;
    default:
      result = 200;
      break;
  }
  res.json({value: result});
});

