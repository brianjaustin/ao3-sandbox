class AddSpamToComments < ActiveRecord::Migration[6.0]
  def up
    if Rails.env.staging? || Rails.env.production?
      database = Comment.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=comments \\
          --alter "ADD COLUMN spam BOOLEAN NOT NULL DEFAULT 0" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_comments_old`;
      PTOSC
    else
      add_column :comments, :spam, :boolean, default: false, null: false
    end
  end

  def down
    if Rails.env.staging? || Rails.env.production?
      database = Comment.connection.current_database

      puts <<~PTOSC
        Schema Change Command:

        pt-online-schema-change D=#{database},t=comments \\
          --alter "DROP COLUMN spam" \\
          --no-drop-old-table \\
          -uroot --ask-pass --chunk-size=5k --max-flow-ctl 0 --pause-file /tmp/pauseme \\
          --max-load Threads_running=15 --critical-load Threads_running=100 \\
          --set-vars innodb_lock_wait_timeout=2 --alter-foreign-keys-method=auto \\
          --execute

        Table Deletion Command:

        DROP TABLE IF EXISTS `#{database}`.`_comments_old`;
      PTOSC
    else
      remove_column :comments, :spam
    end
  end
end
