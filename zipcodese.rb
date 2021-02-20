# 郵便番号検索API
# 提供元サイトおよびリファレンスガイド http://zipcloud.ibsnet.co.jp/doc/api
# Rubyでの使用例　https://qiita.com/KATOH_RYOZO/items/be6f535fc31d7325ed97

require "net/http"
require "json"
require "uri"
require "sqlite3"

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
        puts "#{e}\nエラーコード：#{code}\n#{mes}\nヒント：郵便番号を再度確認の上、もう一度やり直してください。郵便番号は半角で入力してください。"
    else
        e = "ユーザーさん>>エラーが発生しました！"
        mes = hash["message"]
        code = hash["status"]
        puts "#{e}\nエラーコード：#{code}\n#{mes}\nこのエラーについて：API内部のエラーです。"
    end
end

def save_db(data)
    connectdb = SQLite3::Database.new("postcode_cash.db")
    connectdb.execute("insert into p_codedata")
end

if File.exist?("postcode_cash.db")
    puts "postcodeデータベースにすでにデータが存在する場合は、データベースの情報をそのまま使用します。"
else
    puts "データベースがありません。新規作成を行います(新規で実行した場合は必ず表示されます。)"
    dbnew = SQLite3::Database.new "postcode_cash.db"
    create_tb = <<-SQL
    create table post_code (
        id integer prymary key,
        postcode integer,
        address_list text
    )
    SQL
    dbnew.execute( create_tb )
    dbnew.close
    puts "データベースの新規作成が終了しました。"
end
result_address = ""
check_a = ""
puts "郵便番号検索システム"
puts "郵便番号を入力することで、住所を検索する事が出来ます。"
puts "郵便番号を入力してください。"
post_code = gets.chomp
check_a = search_address(post_code)
puts "郵便番号：#{post_code}\n住所：#{check_a}"
dbconnect = SQLite3::Database.new("postcode_cash.db")
dbconnect.execute("insert into post_code (postcode, address_list) values (#{post_code}, '#{check_a}')")
dbconnect.close
puts "検索が完了し、検索したデータをデータベースに記録しました。"
#if chack_a.empty? then
#    puts "検索結果が正常に取得できませんでした。\nヒント：エラーコードが出ているか、存在しない郵便番号を入力した可能性があります。\n値を再度確認の上、再度入力しなおして下さい。"
#else
#    puts "郵便番号：#{post_code}の住所\n住所：#{check_a}"
#    puts "検索が正常に終了しました。今回の検索結果をキャッシュのデータベースに記録しました。\n次回から同じ住所を入力した場合は、データベースから値が入力されます。"
#end