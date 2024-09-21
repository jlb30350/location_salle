namespace :active_storage do
    desc "Purge all unattached ActiveStorage blobs"
    task purge_unattached: :environment do
      ActiveStorage::Blob.unattached.find_each(&:purge)
      puts "All unattached blobs have been purged."
    end
  end
  