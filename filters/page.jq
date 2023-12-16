# page.jq
# generate a page at $index of a metadata file

. + { 
  posts: .posts[$index],
  title: .site.title
} + (
  if ($index > 0) then {
    prevUrl: (
      # if index is 1, previousUrl is / (index)
      # otherwise it's /(index-1)
      if $index == 1 then "/" else (
        "/" + (($index - 1) | tostring)
      ) end
    )
  } else {} end
) + (
  if ($index < (.pages - 1)) then {
    nextUrl: ("/" + (($index + 1) | tostring))
  } else {} end
)