"""chartPatternWinRate Add a column

Revision ID: 2e24d846e135
Revises: 3ee5f7dd1041
Create Date: 2015-10-29 19:36:42.481000

"""

# revision identifiers, used by Alembic.
revision = '2e24d846e135'
down_revision = '3ee5f7dd1041'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('chartPatternWinRate', sa.Column('total', sa.Integer))

def downgrade():
    op.drop_column('chartPatternWinRate', 'total')
