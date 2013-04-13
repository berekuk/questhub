cpan_module 'Flux::File'
cpan_module 'Flux::Format'
cpan_module 'Log::Any::Adapter'

directory "/data/pumper"
directory "/data/storage"
directory "/data/storage/email"
file "/data/storage/email/log" do
    action :create_if_missing
end

cron "email-pumper" do
    command "/play/backend/pumper/sendmail.pl >>/data/pumper/sendmail.log 2>>/data/pumper/sendmail.err.log"
end
