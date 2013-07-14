# -*- coding: utf-8 -*-
module Formotion
  module RowType
    class AsciiRow <  StringRow
      def keyboardType
        UIKeyboardTypeASCIICapable
      end
    end
  end
end

class AccountConfigViewController < Formotion::FormController
  attr_accessor :allow_cancellation

  def init
    if self
      user = ApplicationUser.sharedUser
      form = Formotion::Form.new({
        sections: [{
              title: "はてなアカウント",
              rows: [
                {
                  title: "はてなID",
                  key: "hatena_id",
                  type: :ascii,
                  placeholder: '必須',
                  auto_correction: :no,
                  auto_capitalization: :none,
                  value: user.configured? ? user.hatena_id : nil
                },
                {
                  title: "パスワード",
                  key: "password",
                  type: :string,
                  secure: true,
                  value: user.configured? ? user.password : nil
                }
              ]
            }, {
              title: "設定",
              rows: [
                {
                  title: "新ユーザーページ",
                  key: 'use_timeline',
                  type: 'switch',
                  value: user.use_timeline?
                },
              ]
            }]
      })
      return self.class.alloc.initWithForm(form)
    end
  end

  def viewDidLoad
    super

    self.navigationItem.title = "設定"
    self.view.backgroundColor = UIColor.groupTableViewBackgroundColor

    self.navigationItem.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
      UIBarButtonSystemItemSave,
      target:self,
      action:'save'
    )

    if self.allow_cancellation
      self.navigationItem.leftBarButtonItem  = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
        UIBarButtonSystemItemCancel,
        target:self,
        action:'cancel'
      )
    end
  end

  def cancel
    self.dismissModalViewControllerAnimated(true)
  end

  def save
    data = self.form.render
    if data["hatena_id"].blank?
      App.alert("はてなIDは必須です")
    else
      user = ApplicationUser.sharedUser
      user.hatena_id = data["hatena_id"]
      user.password  = data["password"] || nil
      user.use_timeline = data["use_timeline"]
      user.save
      self.dismissModalViewControllerAnimated(true)
    end
  end
end
