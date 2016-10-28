"""Add a column chartPatternWinRate

Revision ID: 3ee5f7dd1041
Revises: dcbecbd633
Create Date: 2015-10-20 11:33:57.582000

"""

# revision identifiers, used by Alembic.
revision = '3ee5f7dd1041'
down_revision = 'dcbecbd633'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.add_column('chartPatternWinRate', sa.Column('sigma', sa.Float))
    op.add_column('chartPatternWinRate', sa.Column('upDownFlag', sa.String(10)))


def downgrade():
    op.drop_column('chartPatternWinRate', 'sigma')
    op.drop_column('chartPatternWinRate', 'upDownFlag')

