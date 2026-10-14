using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;

namespace Raceway.Data
{
    public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
}
