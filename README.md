# forge link WIP

A very basic plugin to share code snippets, currently from github. 

Ideally in the future I would add the following features.

- links to other code forges
    - way for people to add extra forges as a config option
- generate a markdown snippet 
    - with the correct language tag
    ```LANG
    CODE HERE
    ```

## Testing code highlighting

```javascript
const withDefault = (obj, key, val) => {
  if (obj[key]) return obj[key];
 return val;
};
```


```haskell
data DataField
  = IntValue Int
  | TextValue T.Text
  | NullValue
  deriving (Eq, Show)

type Column = [DataField]

data Csv = Csv
  { csvHeader :: Maybe [T.Text]
  , csvColumns :: [Column]
  }
  deriving (Show)

mkCsv :: Maybe [T.Text] -> [Column] -> E.Either String Csv
mkCsv mHeader columns
  | not headerSizeCorrect =
      E.Left "Size of header row does not fit number of columns"
  | not columnSizesCorrect =
      E.Left "The columns do not have equal sizes"
  | otherwise = Right Csv{csvHeader = mHeader, csvColumns = columns}
 where
  headerSizeCorrect =
    M.maybe True (\h -> L.length h == L.length columns) mHeader
  columnSizesCorrect =
    L.length (L.nubBy (\x y -> length x == length y) columns) <= 1
```

```html
<body class="rails-default-error-page">
    <!-- This file lives in public/500.html -->
    <div class="dialog">
      <div>
        <h1>We're sorry, but something went wrong.</h1>
      </div>
      <p>
        If you are the application owner check the logs for more information.
      </p>
    </div>
  </body>
```


