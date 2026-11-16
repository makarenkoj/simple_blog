namespace :audit do
  desc 'List stored files that are not web images or exceed the upload limit (read-only)'
  task uploaded_blobs: :environment do
    findings = UploadedBlobsAudit.new.call

    puts %w[blob_id created_at content_type byte_size filename reasons attached_to embedded_in_posts].join("\t")
    findings.each do |f|
      attached = f.attachments.map { |a| "#{a.record_type}##{a.record_id}.#{a.name}" }.join(',')
      posts = f.posts.map { |p| "post##{p.id}(user##{p.user_id} #{p.user&.username})" }.join(',')
      puts [f.blob.id, f.blob.created_at.iso8601, f.blob.content_type, f.blob.byte_size,
            f.blob.filename, f.reasons.join('+'), attached.presence || '-', posts.presence || '-'].join("\t")
    end
    puts "# #{findings.size} finding(s); nothing was changed"
  end
end
