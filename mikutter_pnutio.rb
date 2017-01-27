# -*- coding: utf-8 -*-

require_relative 'model'
require_relative 'api'

Plugin.create(:mikutter_pnutio) do
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
                if res_code == Gtk::Dialog::RESPONSE_OK
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
        connect_res = Plugin::Pnutio::API::post "oauth/access_token", {
            "client_id" => UserConfig[:pnutio_client_key],
            "client_secret" => UserConfig[:pnutio_client_secret],
            "code" => UserConfig[:pnutio_auth_code],
            "redirect_uri" => redirect_uri,
            "grant_type" => "authorization_code"
        }
        p connect_res
        if connect_res["meta"]
            dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::ERROR, Gtk::MessageDialog::BUTTONS_OK, "エラー"
            dialog.set_text "pnut.io APIエラー:\n"+connect_res["meta"]["error_message"]
        else
            dialog = Gtk::MessageDialog.new nil, 0, Gtk::MessageType::INFO, Gtk::MessageDialog::BUTTONS_OK, "エラー"
            dialog.set_text "pnut.ioの認証が成功しました！\nアカウント:@"+connect_res["token"]["user"]["username"]+"\nmikutterの設定から”抽出タブ”を選択して、いい感じにやってください。"
            UserConfig[:pnutio_access_token]=connect_res["access_token"]
            UserConfig[:pnutio_scope]=scope
            UserConfig[:pnutio_user_id]=connect_res["user_id"]
            if now_running_home_tick == false
                tick_home
            end
        end
        dialog.run
        dialog.destroy
    end
    filter_extract_datasources do |ds|
        if UserConfig[:pnutio_access_token]
            ds[:pnutio_home] = ["pnut.io","Home"]
        end
        ds[:pnutio_global] = ["pnut.io","Global"]
        [ds]
    end
    def to_post(dict)
        Plugin::Pnutio::Post.new(
            created: dict["created_at"],
            id: dict["id"],
            text: dict["content"]["text"] || "",
            source: dict["source"]["name"]+"(with pnut.io)",
            user: to_user(dict["user"]),
            bookmarksCount: dict["counts"]["bookmarks"],
            repostsCount: dict["counts"]["reposts"],
            repliesCount: dict["counts"]["replies"],
            threadsCount: dict["counts"]["threads"],
            youBookmarked: dict["you_bookmarked"],
            youReposted: dict["you_reposted"]
        )
    end
    def to_user(dict)
        Plugin::Pnutio::User.new(
            id: dict["id"],
            created: dict["created_at"],
            locale: dict["locale"],
            timezone: dict["timezone"],
            type: dict["type"],
            username: dict["username"],
            # TODO: mikutterがidnameをfieldじゃないと表示してくれない不具合が直ったら消す
            idname: dict["username"],
            name: dict["name"],
            profile_text: dict["content"]["text"],
            avatar_image_link: dict["content"]["avatar_image"]["link"],
            avatar_image_height: dict["content"]["avatar_image"]["height"],
            avatar_image_width: dict["content"]["avatar_image"]["width"],
            avatar_image_is_default: dict["content"]["avatar_image"]["is_default"],
            cover_image_link: dict["content"]["cover_image"]["link"],
            cover_image_height: dict["content"]["cover_image"]["height"],
            cover_image_width: dict["content"]["cover_image"]["width"],
            cover_image_is_default: dict["content"]["cover_image"]["is_default"],
            bookmarksCount: dict["counts"]["bookmarks"],
            clientsCount: dict["counts"]["clients"],
            followersCount: dict["counts"]["followers"],
            followingCount: dict["counts"]["following"],
            postsCount: dict["counts"]["posts"],
            usersCount: dict["counts"]["users"],
            follows_you: dict["follows_you"],
            you_blocked: dict["you_blocked"],
            you_follow: dict["you_follow"],
            you_muted: dict["you_muted"],
            you_can_follow: dict["you_can_follow"]
        )
    end
    def tick_home
        now_running_home_tick=true
        res = Plugin::Pnutio::API::get_with_auth("posts/streams/me")["data"]
        res = res.select do |post|
            !post["is_deleted"]
        end
        res = res.map do |post|
            to_post post
        end
        Plugin.call :extract_receive_message, :pnutio_home, res
        Reserver.new(5){ tick_home }
    end
    def tick_global
        if UserConfig[:pnutio_access_token]
            res = Plugin::Pnutio::API::get_with_auth("posts/streams/global")["data"]
        else
            res = Plugin::Pnutio::API::get("posts/streams/global")["data"]
        end
        res = res.select do |post|
            !post["is_deleted"]
        end
        res = res.map do |post|
            to_post post
        end
        Plugin.call :extract_receive_message, :pnutio_global, res
        Reserver.new(5){ tick_global }
    end
    tick_global
    if UserConfig[:pnutio_access_token]
        tick_home
    end
end
