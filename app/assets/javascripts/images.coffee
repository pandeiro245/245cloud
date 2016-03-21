IMG_DIR = 'https://ruffnote.com/attachments'
class ImgURLs
  @visual_header             : "#{IMG_DIR}/24010"
  @visual_whatis             : "#{IMG_DIR}/24501"
  @visual_whatis245cloud     : "#{IMG_DIR}/24942"
  @track_noimage             : "#{IMG_DIR}/24162"
  @track_nomusic             : "#{IMG_DIR}/24981"
  @track_omakase             : "#{IMG_DIR}/24982"
  @track_noimage_hover       : "#{IMG_DIR}/24985"
  @button_play_this_result   : "#{IMG_DIR}/24353"
  @button_play_this_history  : "#{IMG_DIR}/24921"
  @button_play_omakase       : "#{IMG_DIR}/24919"
  @button_play_omakase_hover : "#{IMG_DIR}/24920"
  @button_play_this_hover    : "#{IMG_DIR}/24922"
  @button_paly_nomusic       : "#{IMG_DIR}/24926"
  @button_paly_nomusic_hover : "#{IMG_DIR}/24927"
  @title_rooms               : "#{IMG_DIR}/24967"
  @title_comments            : "#{IMG_DIR}/24968"
  @youbi_sunday              : "#{IMG_DIR}/24465"
  @youbi_monday              : "#{IMG_DIR}/24359"
  @youbi_tuesday             : "#{IMG_DIR}/24360"
  @youbi_wednesday           : "#{IMG_DIR}/24361"
  @youbi_thursday            : "#{IMG_DIR}/24362"
  @youbi_friday              : "#{IMG_DIR}/24363"
  @youbi_saturday            : "#{IMG_DIR}/24464"
  @dotline                   : "#{IMG_DIR}/24944"
  @whitespace                : "#{IMG_DIR}/24966"
  @generate_number_img: (day)->
    img_no = 24371 + day
    "#{IMG_DIR}/#{img_no}"
  @youbi_map: [
    ImgURLs.youbi_sunday
    ImgURLs.youbi_monday
    ImgURLs.youbi_tuesday
    ImgURLs.youbi_wednesday
    ImgURLs.youbi_thursday
    ImgURLs.youbi_friday
    ImgURLs.youbi_saturday
  ]
window.ImgURLs = ImgURLs
