cpan_module 'Flux::File'
cpan_module 'MMCLERIC/Flux-Format-JSON-1.00.tar.gz' # until reindexing is over

directory "/data/pumper"
directory "/data/storage/email"

cron "email-pumper" do
    command "/play/backend/pumper/sendmail.pl >>/data/pumper/sendmail.log 2>>/data/pumper/sendmail.err.log"
end
