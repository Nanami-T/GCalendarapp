require 'google/apis/calendar_v3'
require 'googleauth' # auth=authentication 認証
require 'googleauth/stores/file_token_store'

require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'GoogleCalendar API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "calendar-ruby-quickstart.yaml") # credential 資格
SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
# OpenSSL 暗号通信プロトコルであるSSL及びTLSの機能を実装した
# オープンソース(だれでも自由に使える)のライブラリ

# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
## 有効な資格情報、いずれかの保存された資格情報ファイルからの復元またはのOAuth2認証を
## 開始することによって確認してください。
## 許可が必要な場合、ユーザーのデフォルトブラウザが要求を承認するために起動されます。
## (Google翻訳より)
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize # authorize 認可する
  # メソッドの定義
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
  # FileUtils モジュール 基本的なファイル操作を集めたもの
  # mkdir オプション ディレクトリを作成(CREDENTIALS_PATH)
  # File クラス ファイルアクセスのためのクラス
  # dirname メソッド filename の一番後ろのスラッシュより前を文字列として返す
  ## スラッシュを含まないファイル名に対しては "."(カレントディレクトリ)を返す

  # ::(二重コロン) メソッド呼び出しに利用される レシーバ::メソッド
  # レシーバ object.method()という形式でメソッドを呼び出す際，objectがレシーバ
  ## メッセージを受け取るオブジェクトのこと

  ### ここから
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
      client_id, SCOPE, token_store) # authorizer 承認者
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
        base_url: OOB_URI)
  ### ここまで???
    puts "Open the following URL in the browser and enter the " +
             "resulting code after authorization"
    # ブラウザで次のURLを開き、承認後にコードを入力してください
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# Initialize the API
## initialize 初期化する
service = Google::Apis::CalendarV3::CalendarService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Fetch the next 10 events for the user
calendar_id = 'primary' # prymary 主要
response = service.list_events(calendar_id,
                               max_results: 10, # 最大数
                               single_events: true,
                               order_by: 'startTime',
                               time_min: Time.now.iso8601)

puts "Upcoming events:"
puts "No upcoming events found" if response.items.empty?
response.items.each do|event|
  start = event.start.date || event.start.date_time
  puts "- #{event.summary} (#{start})"
end