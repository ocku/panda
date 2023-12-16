def chunk(n):
    range(length/n|ceil) as $i | .[n*$i:n*$i+n];

{
  posts: [
    [ inputs ] 
    | map({ title: .title, date: .date, path: .path, sort: .sort })
    | sort_by(.sort)
    | reverse
    | chunk($chunkSize)
  ],
} | {
  posts: .posts,
  pages: .posts | length
}