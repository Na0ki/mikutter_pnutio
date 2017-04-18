# -*- coding: utf-8 -*-

require_relative 'model'
require_relative 'api'

Plugin.create(:mikutter_pnutio) do
  # 下の２行は馬鹿にしか見えない
  UserConfig[:pnutio_client_key] ||= "wxpxfSAqUfIFKlwymBw_tFddm6beVRgB"
  UserConfig[:pnutio_client_secret] ||= "KpNzVCVTLBSLGRuvfDA_7TcbsxTQLTYq"
  UserConfig[:pnutio_scope] ||= "noauth"
  redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
  scope = "basic+stream+write_post+update_profile"

  @now_running_home_tick = false

  settings "pnut.io" do
    settings "OAuth" do
      auth = Gtk::Button.new("認証画面を開く")
      auth.signal_connect "clicked" do
        Gtk.openurl('https://pnut.io/oauth/authenticate?client_id=%{client_key}&response_type=code&scope=%{scope}&redirect_uri=%{redirect_uri}' \
        % { client_key: UserConfig[:pnutio_client_key], scope: scope, redirect_uri: redirect_uri })
        dialog = Gtk::Dialog.new "pnut.io コード入力"
        dialog_label = Gtk::Label.new "コードを入力してください。"
        dialog_label.show
        dialog.vbox.pack_start(dialog_label)
        code_input = Gtk::Entry.new
        code_input.show
        dialog.vbox.pack_start(code_input)
        dialog.add_buttons(["OK", Gtk::Dialog::RESPONSE_OK], ["Cancel", Gtk::Dialog::RESPONSE_CANCEL])
        res_code = dialog.run
        p res_code
        if res_code == Gtk::Dialog::RESPONSE_OK
          UserConfig[:pnutio_auth_code] = code_input.text
          Plugin.call(:pnutio_pincode_auth)
        end
        dialog.destroy
        # dialog.destroy
      end
      closeup auth
    end
    settings "多分でんじゃーじゃないゾーン" do
      update_button = Gtk::Button.new "自分の情報を更新する"
      update_button.signal_connect "clicked" do
        if !UserConfig[:pnutio_access_token]
          dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, ""
          dialog.set_text "認証してから出直してこい"
        else
          UserConfig[:pnutio_user_object] = Plugin::Pnutio::API.get_with_auth("users/"+UserConfig[:pnutio_user_id])["data"]
          dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, ""
          dialog.set_text "これで多分更新されました〜。\n一部再起動しないと反映されないのがあるかもしれません。\nおまけ：この機能使うよりmikutter再起動したほうが確実で手軽ですよ"
        end
        dialog.run
        dialog.destroy
      end
      closeup update_button
    end
    settings "でんじゃーぞーん" do
      clear_button = Gtk::Button.new "UserConfigのデータをさっぱりする"
      clear_button.signal_connect "clicked" do
        dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::QUESTION, Gtk::MessageDialog::BUTTONS_YES_NO, "確認"
        dialog.set_text "mikutter_pnutioが利用しているUserConfigのデータをすべて削除します。\n削除したあと、mikutterは終了します。\nよろしいですか？"
        res = dialog.run
        dialog.destroy
        if res == Gtk::Dialog::RESPONSE_YES
          dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::QUESTION, Gtk::MessageDialog::BUTTONS_YES_NO, "確認2"
          dialog.set_text "いいんですか？本当に消えますよ？"
          res = dialog.run
          dialog.destroy
          if res == Gtk::Dialog::RESPONSE_YES
            dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::QUESTION, Gtk::MessageDialog::BUTTONS_YES_NO, "確認2"
            dialog.set_text "これが最後の確認です。\n本当にmikutter_pnutioが利用しているUserConfigを消しても構いませんね？"
            res = dialog.run
            dialog.destroy
            if res == Gtk::Dialog::RESPONSE_YES
              UserConfig[:pnutio_access_token] = nil
              UserConfig[:pnutio_auth_code] = nil
              UserConfig[:pnutio_client_key] = nil
              UserConfig[:pnutio_client_secret] = nil
              UserConfig[:pnutio_user_id] = nil
              UserConfig[:pnutio_user_object] = nil
              UserConfig[:pnutio_scope] = nil
              UserConfig[:pnutio_scope] = nil
              dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, ""
              dialog.set_text "削除しました。\nmikutterを終了します。\n（セグフォするけど気にしないでおくれ）"
              dialog.run
              # デンジャーポイント：これをやるとセグフォする
              exit
            else
              dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, ""
              dialog.set_text "ギリギリセーフ！よかった〜〜"
            end
          else
            dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, ""
            dialog.set_text "残念！確認ダイアログはもう一つあるんだな〜これが"
          end
        else
          dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, ""
          dialog.set_text "なんだよ、消さねえのかよ"
        end
        dialog.run
        dialog.destroy
      end
      closeup clear_button
    end
  end

  on_pnutio_pincode_auth do
    Plugin::Pnutio::API.post("oauth/access_token", {
        "client_id" => UserConfig[:pnutio_client_key],
        "client_secret" => UserConfig[:pnutio_client_secret],
        "code" => UserConfig[:pnutio_auth_code],
        "redirect_uri" => redirect_uri,
        "grant_type" => "authorization_code"
    }).next { |connect_res|
      notice connect_res
      if connect_res['meta']
        Delayer.new do
          dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::ERROR, Gtk::MessageDialog::BUTTONS_OK, "エラー"
          dialog.set_text "pnut.io APIエラー:\n#{connect_res['meta']['error_message']}"
          dialog.run
          dialog.destroy
        end
      else
        Delayer.new do
          dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, "エラー"
          dialog.set_text "pnut.ioの認証が成功しました！\nアカウント:@%{user_name}\nmikutterの設定から”抽出タブ”を選択して、いい感じにやってください。" \
      % { user_name: connect_res['token']['user']['username'] }
          UserConfig[:pnutio_access_token] = connect_res['access_token']
          UserConfig[:pnutio_scope] = scope
          UserConfig[:pnutio_user_id] = connect_res['user_id']
          UserConfig[:pnutio_user_object] = Plugin::Pnutio::API.get_with_auth("users/#{UserConfig[:pnutio_user_id]}")['data']
          tick_home unless @now_running_home_tick
          dialog.run
          dialog.destroy
        end
      end
    }.trap { |err| error err }
  end

  filter_extract_datasources do |ds|
    ds[:pnutio_home] = 'pnut.io Home' if UserConfig[:pnutio_access_token]
    ds[:pnutio_global] = 'pnut.io Global'
    [ds]
  end

  def format_message(data)
    data.reject { |post|
      post['is_deleted']
    }.map { |post|
      Plugin::Pnutio::Post.for_dict(post)
    }
  end

  def tick_home
    @now_running_home_tick = true
    Plugin::Pnutio::API.get_with_auth('posts/streams/me').next { |res|
      message = format_message(res['data'])
      Plugin.call(:extract_receive_message, :pnutio_home, message)
      Reserver.new(5) { tick_home }
    }.trap { |err| error err }
  end

  def tick_global
    if UserConfig[:pnutio_access_token]
      Plugin::Pnutio::API.get_with_auth('posts/streams/global').next { |res|
        message = format_message(res['data'])
        Plugin.call(:extract_receive_message, :pnutio_global, message)
        Reserver.new(5) { tick_global }
      }.trap { |err| error err }
    else
      Plugin::Pnutio::API.get('posts/streams/global')['data'].next { |res|
        message = format_message(res['data'])
        Plugin.call(:extract_receive_message, :pnutio_global, message)
        Reserver.new(5) { tick_global }
      }.trap { |err| error err }
    end
  end

  tick_global
  if UserConfig[:pnutio_access_token]
    Plugin::Pnutio::API.get_with_auth("users/#{UserConfig[:pnutio_user_id]}").next { |res|
      UserConfig[:pnutio_user_object] = res['data']
      tick_home
    }.trap { |err| error err }
  end
end
