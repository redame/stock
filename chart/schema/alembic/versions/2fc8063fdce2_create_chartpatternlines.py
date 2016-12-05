"""create chartPatternLines

Revision ID: 2fc8063fdce2
Revises: 3a4d57f834e6
Create Date: 2015-08-24 19:07:36.288000

"""

# revision identifiers, used by Alembic.
revision = '2fc8063fdce2'
down_revision = '3a4d57f834e6'
branch_labels = None
depends_on = None

from alembic import op
import sqlalchemy as sa


def upgrade():
    op.create_table(
        'chartPatternLines',
        sa.Column('id', sa.Integer, primary_key=True),
        sa.Column('lineID', sa.String(100), nullable=False),
        sa.Column('startTime', sa.TIMESTAMP, nullable=False),
        sa.Column('startPrice', sa.Float, nullable=False),
        sa.Column('endTime', sa.TIMESTAMP, nullable=False),
        sa.Column('endPrice', sa.Float, nullable=False),
    )
    pass


def downgrade():
    op.drop_table('chartPatternLines')
    pass
