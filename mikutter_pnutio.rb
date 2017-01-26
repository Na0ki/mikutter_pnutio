# -*- coding: utf-8 -*-

## い つ も の
require 'net/https'
require 'json'
require 'uri'

Plugin.create(:mikutter_pnutio) do
    defactivity "pnutio", "pnut.io"
    def api_get(endpoint)
        res = Net::HTTP.get URI.parse('https://api.pnut.io/v0/'+endpoint)
        JSON.parse(res)
    end
    def api_post(endpoint, params)
        res = Net::HTTP.post_form URI.parse('https://api.pnut.io/v0/'+endpoint), params
        JSON.parse(res.body)
    end
    UserConfig[:pnutio_client_key] ||= "wxpxfSAqUfIFKlwymBw_tFddm6beVRgB"
    UserConfig[:pnutio_client_secret] ||= "KpNzVCVTLBSLGRuvfDA_7TcbsxTQLTYq"
    UserConfig[:pnutio_scope] ||= "noauth"
    redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
    scope = "basic+stream+write_post+update_profile"
    settings "pnut.io" do 
        settings "OAuth" do 
            auth = Gtk::Button.new("認証画面を開く")
            auth.signal_connect "clicked" do
                Gtk::openurl("https://pnut.io/oauth/authenticate?client_id="+UserConfig[:pnutio_client_key]+"&response_type=code&scope="+scope+"&redirect_uri="+redirect_uri)
                dialog = Gtk::Dialog.new "pnut.io コード入力"
                dialog_label = Gtk::Label.new "コードを入力してください。"
                dialog_label.show
                dialog.vbox.pack_start(dialog_label)
                code_input = Gtk::Entry.new
                code_input.show
                dialog.vbox.pack_start(code_input)
                dialog.add_buttons(["OK",Gtk::Dialog::RESPONSE_OK],["Cancel",Gtk::Dialog::RESPONSE_CANCEL])
                res_code = dialog.run
                p res_code
                if res_code == Gtk::Dialog::RESPONSE_OK then
                    UserConfig[:pnutio_auth_code] = code_input.text
                    Plugin.call(:pnutio_pincode_auth)
                end
                dialog.destroy
                # dialog.destroy
            end
            closeup auth
        end
    end
    on_pnutio_pincode_auth do
        connect_res = api_post "oauth/access_token", {
            "client_id" => UserConfig[:pnutio_client_key],
            "client_secret" => UserConfig[:pnutio_client_secret],
            "code" => UserConfig[:pnutio_auth_code],
            "redirect_uri" => redirect_uri,
            "grant_type" => "authorization_code"
        }
        p connect_res
        if connect_res["meta"] then
            dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::ERROR, Gtk::MessageDialog::BUTTONS_OK, "エラー"
            dialog.set_text "pnut.io APIエラー:\n"+connect_res["meta"]["error_message"]
        else
            dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, "エラー"
            dialog.set_text "pnut.ioの認証が成功しました！\nアカウント:@"+connect_res["token"]["user"]["username"]+"\nmikutterを再起動してください。"
            UserConfig[:pnutio_access_token]=connect_res["access_token"]
            UserConfig[:pnutio_scope]=scope
        end
        dialog.run
        dialog.destroy
    end
end
