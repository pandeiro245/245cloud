$ ->
  Util.scaffolds([
    ['header', {is_row: false}]
    'news'
    'footer'
  ], 'np')
  Util.realtime()
  ruffnote(23812, 'header')
  ruffnote(23813, 'news')
  ruffnote(23814, 'footer')
