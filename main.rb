# frozen_string_literal: true

require 'google/cloud/vision'

def main(images:)
  image_annotator = Google::Cloud::Vision.image_annotator
  descriptions = images.map do |image|
    response = image_annotator.text_detection(image:)
    response.responses.map do |res|
      res.text_annotations.first.description
    end
  end

  puts descriptions
end

main images: %w[tmp/sample1.jpeg tmp/sample2.jpeg]

# 本日の運動結果
# R 画面を撮影する
# キミとプライム
# 14分42秒
# 合計活動時間
# 42.40kcal
# 合計消費力ロリー
# 文
# 0.
# 合計走行距離
# 50km
# 1次へ
# 本日の運動結果
# キミとプライム
# R 画面を撮影する
# バンザイコシフリ
# 138回(138回)
# リングコン下押しこみ
# 5回(49回)
# アームツイスト
# 138回(465回)
# おなか押しこみスクワット
# 10(20)
# 英雄1のポーズ
# 60回(324回)
# サイレントダッシュ
# 314m(5745m)
# リングコン押しこみ
# 55回(1159回)
# * サイレントジョギング
# 169m(3148m)
# * スクワット
# 30回(308回)
# サイレントモモ上げ
# 22m(177m)
# リングアロー
# 26回(558回)
# サイレントウォーク
# 1m(1m)
# ワイドスクワット
# 20回(40回)
# リングコン上引っぱり
# 17秒(50秒)
# 扇のポーズ
# 12回(48回)
# リングコン引っぱりキープ
# 6秒(309秒)
# おなか押しこみ
# 7回(144回)
# リングコン下押しこみキープ
# 0秒(94秒)
# カッコ内はプレイ開始からの累計値です
# とじる
