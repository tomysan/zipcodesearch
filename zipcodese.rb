# 郵便番号検索API
# 提供元サイトおよびリファレンスガイド http://zipcloud.ibsnet.co.jp/doc/api
# Rubyでの使用例　https://qiita.com/KATOH_RYOZO/items/be6f535fc31d7325ed97

require "net/http"
require "json"
require "uri"

def search_address(post_code)
    res = Net::HTTP.get(URI.parse("https://zipcloud.ibsnet.co.jp/api/search?zipcode=#{post_code}"))
    hash = JSON.parse(res)
    #郵便番号のチェック
    if hash["status"] == 200
        return hash["results"][0].values.take(3).join("")
    elsif hash["status"] == 400
        e = "ユーザーさん>>エラーが発生しました！"
        mes = hash["message"]
        code = hash["status"]
        return "#{e}\nエラーコード：#{code}\n#{mes}\nヒント：郵便番号を再度確認の上、もう一度やり直してください。郵便番号は半角で入力してください。"
    else
        e = "ユーザーさん>>エラーが発生しました！"
        mes = hash["message"]
        code = hash["status"]
        return "#{e}\nエラーコード：#{code}\n#{mes}\nこのエラーについて：API内部のエラーです。"
    end
end

result_address = ""
puts "郵便番号検索システム"
puts "郵便番号を入力することで、住所を検索する事が出来ます。"
puts "郵便番号を入力してください。"
post_code = gets.chomp
puts search_address(post_code)
puts "検索が終了しました。"