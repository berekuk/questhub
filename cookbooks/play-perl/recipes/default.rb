require_recipe "mongodb"

package 'vim'
package 'git'
package 'libdancer-perl'

include_recipe "mongodb::default"
